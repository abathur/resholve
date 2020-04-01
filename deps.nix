{ stdenv, fetchFromGitHub, makeWrapper,

git,

# oil deps
readline, re2c, cmark, python27, file,
}:

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
    # just for submodule IIRC
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
      rev = "0f8b51518690db74470da041eb5fd104d1c90e23";
      sha256 = "0bpg6jq3nnx23hrxs4jg03vgkcxdbqgc36qjq3hhzrwlc0bgysw3";
    };

    buildInputs = [ readline cmark py-yajl makeWrapper ];

    nativeBuildInputs = [ re2c file ];

    # runtime deps
    propagatedBuildInputs = with python27.pkgs; [ python27 six typing ];

    doCheck = true;
    dontStrip = true;

    preBuild = ''
      build/dev.sh all
    '';

    # Patch shebangs so Nix can find all executables
    postPatch = ''
      patchShebangs asdl build core doctools frontend native oil_lang
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
