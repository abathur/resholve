{ pkgs ? import <nixpkgs> {} }:

with pkgs; let
  resholved = callPackage ./default.nix {};
  pytest-shell = python37.pkgs.buildPythonPackage {
    name = "pytest-shell-0.2.3";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/ad/ae/7f4dfcab9b74e272674315f4b9141185d2a9072569fa334dd1facebb2234/pytest-shell-0.2.3.tar.gz";
      sha256 = "535178a527450371defbc00e542511300b6a8e3199abe537b31aae6eb3c94ded";
    };
    buildInputs = [ ];
    propagatedBuildInputs = [
      python37.pkgs.pytest
    ];
    meta = {
      homepage = "https://hg.sr.ht/~danmur/pytest-shell";
      license = stdenv.lib.licenses.mit;
      description = "Pytest plugin for running shell commands/scripts.";
    };
  };
  shunit2 = with pkgs.shunit2; resholved.buildResholvedPackage {
    inherit name src version installPhase;
    scripts = [ "shunit2" ];
    inputs = [ coreutils gnused gnugrep findutils ];
    patchPhase = ''
      substituteInPlace shunit2 --replace "/usr/bin/od" "od"
    '';
    allow = {
      eval = ["shunit_condition_" "_shunit_test_"];
      # dynamically defined in shunit2:_shunit_mktempFunc
      function = [ "oneTimeSetUp" "oneTimeTearDown" "setUp" "tearDown" "suite" "noexec"];
      builtin = [ "setopt" ]; # zsh has it, not sure
    };
  };
  test_module1 = resholved.buildResholvedPackage {
    name = "testmod1";
    version = "unreleased";

    src = lib.cleanSource tests/nix/libressl/.;

    scripts = ["libressl.sh"];
    inputs = [ jq test_module2 libressl.bin ];
    allow = { };

    installPhase = ''
      mkdir -p $out/bin
      install libressl.sh $out/bin/libressl.sh
    '';
  };
  test_module2 = resholved.buildResholvedPackage {
    name = "testmod2";
    version = "unreleased";

    src = lib.cleanSource tests/nix/openssl/.;

    scripts = ["openssl.sh"];
    inputs = [ shunit2 openssl.bin ];

    installPhase = ''
      mkdir -p $out/bin
      install openssl.sh $out/bin/openssl.sh
    '';
  };
  test_module3 = resholved.buildResholvedPackage {
    name = "testmod3";
    version = "unreleased";

    src = lib.cleanSource tests/nix/future_perfect_tense/.;

    scripts = ["conjure.sh"];
    inputs = [ test_module1 ];
    allow = { };

    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
    '';
  };
  testPy = python37.withPackages (ps: with ps; [ pytest pytest-shell ]);
  resolveTimeDeps = [ file gettext ];
# in symlinkJoin {
#   name = "GFY";
#   paths = [ resholved testPy ];
#   postBuild = ''
#       PATH=$out/bin:$PATH
#       echo $PATH
#       ls -la
#       type -pa resholver python python2 python3 pytest || true
#       echo ${demo}
#       ls -la ${demo}
#       pushd ${demo}
#       pytest
#       # pytest tests
#     '';
# }
in stdenv.mkDerivation {
  name = "resholved-ci";
  src = builtins.filterSource (path: type: type != "directory" || baseNameOf path == "demo" || baseNameOf path == "tests") ./.;
  installPhase = ''
    mkdir $out
  '';
  doCheck = true;
  buildInputs = [ resholved.resholved bat ];
  propagatedBuildInputs = [ test_module3 ];
  checkInputs = [ testPy ];

  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";
  checkPhase = ''
    printf "\033[33m============================= resholver demo ===================================\033[0m\n"
    pytest demo
    printf "\033[33m============================= resholver Nix demo ===============================\033[0m\n"
    env -i $(type -p conjure.sh)
    bat --paging=never --color=always $(type -p conjure.sh openssl.sh libressl.sh)
  '';
}
