{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholve = callPackage ./default.nix { };
  shunit2 = with pkgs.shunit2;
    resholve.resholvePackage {
      inherit pname src version installPhase;
      scripts = [ "bin/shunit2" ];
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
  test_module1 = resholve.resholvePackage {
    pname = "testmod1";
    version = "unreleased";

    src = lib.cleanSource tests/nix/libressl/.;

    # submodule to demonstrate
    scripts = [ "bin/libressl.sh" "submodule/helper.sh" ];
    inputs = [ jq test_module2 libressl.bin ];
    allow = { };

    installPhase = ''
      mkdir -p $out/{bin,submodule}
      install libressl.sh $out/bin/libressl.sh
      install submodule/helper.sh $out/submodule/helper.sh
    '';
  };
  test_module2 = resholve.resholvePackage {
    pname = "testmod2";
    version = "unreleased";

    src = lib.cleanSource tests/nix/openssl/.;
    # no aliases here, so this has no impact--just using it
    # to illustrate the Nix API, and have a test that'll break
    flags = [ "--resolve-aliases" ];
    scripts = [ "bin/openssl.sh" ];
    inputs = [ shunit2 openssl.bin ];

    installPhase = ''
      mkdir -p $out/bin
      install openssl.sh $out/bin/openssl.sh
    '';
  };
  test_module3 = resholve.resholvePackage {
    pname = "testmod3";
    version = "unreleased";

    src = lib.cleanSource tests/nix/future_perfect_tense/.;

    scripts = [ "bin/conjure.sh" ];
    inputs = [ test_module1 ];

    # TODO: try install -Dt $out/bin $src/yadm
    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
    '';
  };
  resolveTimeDeps = [ file findutils gettext ];

in stdenv.mkDerivation {
  name = "resholve-ci";
  src = builtins.filterSource (path: type:
    type != "directory" || baseNameOf path
    == "tests") ./.;
  installPhase = ''
    mkdir $out
  '';
  doCheck = true;
  buildInputs = [ resholve.resholve bat ];
  propagatedBuildInputs = [ test_module3 ];
  checkInputs = [ bats ];

  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";

  # explicit interpreter for demo suite; maybe some better way...
  INTERP = "${bash}/bin/bash";

  checkPhase = ''
    patchShebangs .
    printf "\033[33m============================= resholver demo ===================================\033[0m\n"
    ./demo

    printf "\033[33m============================= resholver Nix demo ===============================\033[0m\n"
    env -i $(type -p conjure.sh)
    bat --paging=never --color=always $(type -p conjure.sh ${test_module2}/bin/openssl.sh ${test_module1}/bin/libressl.sh)
  '';
}
