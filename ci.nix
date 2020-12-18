{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholve = callPackage ./default.nix { };
  shunit2 = with pkgs.shunit2;
    resholve.resholvePackage {
      inherit pname src version installPhase;
      solutions = {
        shunit = {
          interpreter = "none";
          scripts = [ "bin/shunit2" ];
          inputs = [ coreutils gnused gnugrep findutils ];
          # resholve's Nix API is analogous to the CLI flags
          # documented in 'man resholve'
          fake = {
            # "missing" functions shunit2 expects the user to declare
            function = [
              "oneTimeSetUp"
              "oneTimeTearDown"
              "setUp"
              "tearDown"
              "suite"
              "noexec"
            ];
            # shunit2 is both bash and zsh compatible, and in
            # some zsh-specific code it uses this non-bash builtin
            builtin = [ "setopt" ];
          };
          fix = {
            # stray absolute path; make it resolve from coreutils
            "/usr/bin/od" = true;
          };
          keep = {
            # dynamically defined in shunit2:_shunit_mktempFunc
            eval = [ "shunit_condition_" "_shunit_test_" ];

            # variables invoked as commands; long-term goal is to
            # resolve the *variable*, but that is complexish, so
            # this is where we are...
            "$__SHUNIT_CMD_ECHO_ESC" = true;
            "$_SHUNIT_LINENO_" = true;
            "$SHUNIT_CMD_TPUT" = true;
          };
        };
      };
    };
  test_module1 = resholve.resholvePackage {
    pname = "testmod1";
    version = "unreleased";

    src = lib.cleanSource tests/nix/libressl/.;

    installPhase = ''
      mkdir -p $out/{bin,submodule}
      install libressl.sh $out/bin/libressl.sh
      install submodule/helper.sh $out/submodule/helper.sh
    '';

    solutions = {
      libressl = {
        # submodule to demonstrate
        scripts = [ "bin/libressl.sh" "submodule/helper.sh" ];
        interpreter = "none";
        inputs = [ jq test_module2 libressl.bin ];
      };
    };

    is_it_okay_with_arbitrary_envs = "shonuff";
  };
  test_module2 = resholve.resholvePackage {
    pname = "testmod2";
    version = "unreleased";

    src = lib.cleanSource tests/nix/openssl/.;

    installPhase = ''
      mkdir -p $out/bin
      install openssl.sh $out/bin/openssl.sh
      install profile $out/profile
    '';

    solutions = {
      openssl = {
        fix = {
          aliases = true;
        };
        scripts = [ "bin/openssl.sh" ];
        interpreter = "none";
        inputs = [ shunit2 openssl.bin ];
      };
      profile = {
        scripts = [ "profile" ];
        interpreter = "none";
        inputs = [ ];
      };
    };
  };
  test_module3 = resholve.resholvePackage {
    pname = "testmod3";
    version = "unreleased";

    src = lib.cleanSource tests/nix/future_perfect_tense/.;

    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
    '';

    solutions = {
      conjure = {
        scripts = [ "bin/conjure.sh" ];
        interpreter = "${bash}/bin/bash";
        inputs = [ test_module1 ];
      };
    };
  };
  resolveTimeDeps = [ file findutils gettext ];

in
stdenv.mkDerivation {
  name = "resholve-ci";
  src = builtins.filterSource
    (path: type:
      type != "directory" || baseNameOf path
      == "tests") ./.;
  installPhase = ''
    mkdir $out
    cp *demo.txt $out/
  '';
  doCheck = true;
  buildInputs = [ resholve.resholve bat ansifilter ];
  propagatedBuildInputs = [ test_module3 ];
  checkInputs = [ bats ];

  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";

  # explicit interpreter for demo suite; maybe some better way...
  INTERP = "${bash}/bin/bash";

  checkPhase = ''
    patchShebangs .
    printf "\033[33m============================= resholve demo ===================================\033[0m\n"
    ./demo |& tee demo.ansi

    printf "\033[33m============================= resholve Nix demo ===============================\033[0m\n"
    env -i $(type -p conjure.sh) |& tee nix-demo.ansi
    bat --paging=never --color=always $(type -p conjure.sh ${test_module2}/bin/openssl.sh ${test_module1}/bin/libressl.sh) |& tee -a nix-demo.ansi
    ansifilter -o demo.txt --text demo.ansi
    ansifilter -o nix-demo.txt --text nix-demo.ansi
  '';
}
