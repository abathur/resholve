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

  oildev = python27.pkgs.buildPythonPackage rec {
    pname = "oil";
    version = "undefined";

    src = fetchFromGitHub {
      owner = "abathur";
      repo = "oil";
      rev = "259e582598689cb5077c44819f3234dda79c34fa";
      sha256 = "0rx68y8r82sr8qmbr806iaz2pispn02f64k6xywxpj5lx05jynlz";
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

    prePatch = ''
      substituteInPlace ./doctools/cmark.py --replace "/usr/local/lib/libcmark.so" "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}"
    '';

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
