{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholved = callPackage ./default.nix { };
  shunit2 = with pkgs.shunit2;
    resholved.buildResholvedPackage {
      inherit pname src version installPhase;
      scripts = [ "shunit2" ];
      inputs = [ coreutils gnused gnugrep findutils ];
      patchPhase = ''
        substituteInPlace shunit2 --replace "/usr/bin/od" "od"
      '';
      allow = {
        eval = [ "shunit_condition_" "_shunit_test_" ];
        # dynamically defined in shunit2:_shunit_mktempFunc
        function = [
          "oneTimeSetUp"
          "oneTimeTearDown"
          "setUp"
          "tearDown"
          "suite"
          "noexec"
        ];
        builtin = [ "setopt" ]; # zsh has it, not sure
      };
    };
  test_module1 = resholved.buildResholvedPackage {
    pname = "testmod1";
    version = "unreleased";

    src = lib.cleanSource tests/nix/libressl/.;

    scripts = [ "libressl.sh" ];
    inputs = [ jq test_module2 libressl.bin ];
    allow = { };

    installPhase = ''
      mkdir -p $out/bin
      install libressl.sh $out/bin/libressl.sh
    '';
  };
  test_module2 = resholved.buildResholvedPackage {
    pname = "testmod2";
    version = "unreleased";

    src = lib.cleanSource tests/nix/openssl/.;

    scripts = [ "openssl.sh" ];
    inputs = [ shunit2 openssl.bin ];

    installPhase = ''
      mkdir -p $out/bin
      install openssl.sh $out/bin/openssl.sh
    '';
  };
  test_module3 = resholved.buildResholvedPackage {
    pname = "testmod3";
    version = "unreleased";

    src = lib.cleanSource tests/nix/future_perfect_tense/.;

    scripts = [ "conjure.sh" ];
    inputs = [ test_module1 ];
    allow = { };

    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
    '';
  };
  resolveTimeDeps = [ file gettext ];

in stdenv.mkDerivation {
  name = "resholved-ci";
  src = builtins.filterSource (path: type:
    type != "directory" || baseNameOf path == "demo" || baseNameOf path
    == "tests") ./.;
  installPhase = ''
    mkdir $out
  '';
  doCheck = true;
  buildInputs = [ resholved.resholved bat ];
  propagatedBuildInputs = [ test_module3 ];
  checkInputs = [ bats ];

  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";
  checkPhase = ''
    printf "\033[33m============================= resholver demo ===================================\033[0m\n"
    RESHOLVE_DEMO=1 bats -t tests/demo.bats

    printf "\033[33m============================= resholver Nix demo ===============================\033[0m\n"
    env -i $(type -p conjure.sh)
    bat --paging=never --color=always $(type -p conjure.sh openssl.sh libressl.sh)
  '';
}
