{ lib
, stdenv
, callPackage
, resholve
, resholvePackage
, resholveScript
, resholveScriptBin
# , shunit2
, ncurses
, fetchFromGitHub
, coreutils
, gnused
, gnugrep
, findutils
, jq
, bash
, bats
, libressl
, openssl
, python27
, file
, gettext
, rSrc
, runDemo ? false
, binlore
, sqlite
, util-linux
, gawk
, rlwrap
, gnutar
, bc
}:

let
  default_packages = [ bash file findutils gettext ];
  parsed_packages = [ coreutils sqlite util-linux gnused gawk findutils rlwrap gnutar bc ];
in
rec {
  shunit2 = resholvePackage rec {
    pname = "shunit2";
    version = "2.1.8";

    src = fetchFromGitHub {
      owner = "kward";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-IZHkgkVqzeh+eEKCDJ87sqNhSA+DU6kBCNDdQaUEeiM=";
    };

    installPhase = ''
      mkdir -p $out/bin/
      cp ./shunit2 $out/bin/shunit2
      chmod +x $out/bin/shunit2
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/shunit2
    '';

    solutions = {
      shunit = {
        # Caution: see __SHUNIT_CMD_ECHO_ESC before changing
        interpreter = "${bash}/bin/sh";
        scripts = [ "bin/shunit2" ];
        inputs = [ coreutils gnused gnugrep findutils ncurses ];
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
          /*
          Caution: this one is contextually debatable. shunit2
          sets this variable after testing whether `echo -e test`
          yields `test` or `-e test`. Since we're setting the
          interpreter, we can pre-test this. But if we go fiddle
          the interpreter later, I guess we _could_ break it.
          */
          "$__SHUNIT_CMD_ECHO_ESC" = [ "echo -e" ];
          "$SHUNIT_CMD_TPUT" = [ "tput" ]; # from ncurses
        };
        keep = {
          # dynamically defined in shunit2:_shunit_mktempFunc
          eval = [ "shunit_condition_" "_shunit_test_" "_shunit_prepForSourcing" ];

          # dynamic based on CLI flag
          "$_SHUNIT_LINENO_" = true;
        };
        execer = [
          # drop after https://github.com/abathur/binlore/issues/2
          "cannot:${ncurses}/bin/tput"
        ];
      };
    };

    meta = with lib; {
      homepage = "https://github.com/kward/shunit2";
      description = "An xUnit based unit test framework for Bourne based shell scripts";
      maintainers = with maintainers; [ abathur utdemir ];
      license = licenses.asl20;
      platforms = platforms.unix;
    };
  };
  module1 = resholvePackage {
    pname = "testmod1";
    version = "unreleased";

    src = rSrc;
    setSourceRoot = "sourceRoot=$(echo */tests/nix/libressl)";

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
        inputs = [ jq module2 libressl.bin ];
      };
    };

    is_it_okay_with_arbitrary_envs = "shonuff";
  };
  module2 = resholvePackage {
    pname = "testmod2";
    version = "unreleased";

    src = rSrc;
    setSourceRoot = "sourceRoot=$(echo */tests/nix/openssl)";

    installPhase = ''
      mkdir -p $out/bin $out/libexec
      install openssl.sh $out/bin/openssl.sh
      install libexec.sh $out/libexec/invokeme
      install profile $out/profile
    '';
    # LOGLEVEL="DEBUG";
    solutions = {
      openssl = {
        fix = {
          aliases = true;
        };
        scripts = [ "bin/openssl.sh" "libexec/invokeme" ];
        interpreter = "none";
        inputs = [ shunit2 openssl.bin "libexec" "libexec/invokeme" ];
        execer = [
          /*
            This is the same verdict binlore will
            come up with. It's a no-op just to demo
            how to fiddle lore via the Nix API.
          */
          "cannot:${openssl.bin}/bin/openssl"
          # different verdict, but not used
          "can:${openssl.bin}/bin/c_rehash"
        ];
      };
      profile = {
        scripts = [ "profile" ];
        interpreter = "none";
        inputs = [ ];
      };
    };
  };
  module3 = resholvePackage {
    pname = "testmod3";
    version = "unreleased";

    src = rSrc;
    setSourceRoot = "sourceRoot=$(echo */tests/nix/future_perfect_tense)";

    installPhase = ''
      mkdir -p $out/bin
      install conjure.sh $out/bin/conjure.sh
    '';

    solutions = {
      conjure = {
        scripts = [ "bin/conjure.sh" ];
        interpreter = "${bash}/bin/bash";
        inputs = [ module1 ];
        fake = {
          external = [ "jq" "openssl" ];
        };
      };
    };
  };

  cli = stdenv.mkDerivation {
    name = "resholve-test";
    src = rSrc;
    installPhase = ''
      mkdir $out
      cp *.ansi $out/
    '';
    doCheck = true;
    buildInputs = [ resholve ];
    checkInputs = [ coreutils bats python27 ];
    # LOGLEVEL="DEBUG";

    # default path
    RESHOLVE_PATH = "${lib.makeBinPath default_packages}";
    # but separate packages for combining as needed
    PKG_FILE = "${lib.makeBinPath [ file ]}";
    PKG_FINDUTILS = "${lib.makeBinPath [ findutils ]}";
    PKG_GETTEXT = "${lib.makeBinPath [ gettext ]}";
    PKG_COREUTILS = "${lib.makeBinPath [ coreutils ]}";
    RESHOLVE_LORE = "${binlore.collect { drvs = default_packages ++ [ coreutils ] ++ parsed_packages; } }";
    PKG_PARSED = "${lib.makeBinPath parsed_packages}";

    # explicit interpreter for demo suite; maybe some better way...
    INTERP = "${bash}/bin/bash";

    checkPhase = ''
      patchShebangs .
      mkdir empty_lore
      touch empty_lore/{execers,wrappers}
      export EMPTY_LORE=$PWD/empty_lore
      printf "\033[33m============================= resholve test suite ===================================\033[0m\n" > test.ansi
      if ./test.sh &>> test.ansi; then
        cat test.ansi
      else
        cat test.ansi && exit 1
      fi
    '' + lib.optionalString runDemo ''
      printf "\033[33m============================= resholve demo ===================================\033[0m\n" > demo.ansi
      if ./demo &>> demo.ansi; then
        cat demo.ansi
      else
        cat demo.ansi && exit 1
      fi
    '';
  };

  # Caution: ci.nix asserts the equality of both of these w/ diff
  resholvedScript = resholveScript "resholved-script" {
    inputs = [ file ];
    interpreter = "${bash}/bin/bash";
  } ''
    echo "Hello"
    file .
  '';
  resholvedScriptBin = resholveScriptBin "resholved-script-bin" {
    inputs = [ file ];
    interpreter = "${bash}/bin/bash";
  } ''
    echo "Hello"
    file .
  '';
}
