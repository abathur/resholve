{ stdenv, fetchFromGitHub, fetchurl, makeWrapper,

git,

# oil deps
readline, re2c, cmark, python27, file,

# resholved test deps
python37, }:

rec {
  py-yajl = python27.pkgs.buildPythonPackage rec {
    pname = "oil-pyyajl";
    version = "unreleased";
    src = fetchFromGitHub {
      owner = "oilshell";
      repo = "py-yajl";
      rev = "eb561e9aea6e88095d66abcc3990f2ee1f5339df";
      sha256 = "17hcgb7r7cy8r1pwbdh8di0nvykdswlqj73c85k6z8m0filj3hbh";
      fetchSubmodules = true;
    };
    nativeBuildInputs = [ git ];
  };

  # resholved's primary dependency is this developer build of the oil shell.
  oildev = python27.pkgs.buildPythonPackage rec {
    pname = "oil";
    version = "undefined";

    # I've gotten most of the changes we need upstreamed at this point, but I've still got a few they've resisted. For the near term, I've given up trying.
    # - add setup.py
    # - add MANIFEST.in,
    # - change build/codegen.sh's shebang to /usr/bin/env bash
    # - comment out the 'yajl' function call in _minimal() of build/dev.sh
    src = fetchFromGitHub {
      owner = "abathur";
      repo = "oil";
      rev = "548205595d3d5f968cad5843f997adaf6969753b";
      sha256 = "11pn454iqrq2zkmnihwmsav9yj3vjaj8nljh43zjk28sw46incwi";
    };

    buildInputs = with python27.pkgs;
      [ six typing ]
      ++ [ python27 readline re2c cmark py-yajl makeWrapper ];

    nativeBuildInputs = [ re2c file python27 py-yajl ];

    pythonPath = with python27.pkgs; [ six typing ];

    # runtime deps
    propagatedBuildInputs = [ re2c py-yajl ];

    doCheck = true;
    dontStrip = true;

    preBuild = ''
      echo $buildPhase
      set -x
      build/dev.sh all
      set +x
    '';

    # Patch shebangs so Nix can find all executables
    postPatch = ''
      patchShebangs asdl build core frontend native oil_lang
    '';

    _NIX_SHELL_LIBCMARK = "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}";

    meta = {
      description = "A new unix shell";
      homepage = "https://www.oilshell.org/";
      license = with stdenv.lib.licenses; [
        psfl # Includes a portion of the python interpreter and standard library
        asl20 # Licence for Oil itself
      ];
    };
  };
}
