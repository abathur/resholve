{ stdenv, fetchFromGitHub, makeWrapper,

git,

# oil deps
readline, re2c, cmark, python27, file, glibcLocales
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

    src = fetchFromGitHub {
      owner = "oilshell";
      repo = "oil";
      rev = "ea80cdad7ae1152a25bd2a30b87fe3c2ad32394a";
      sha256 = "0pxn0f8qbdman4gppx93zwml7s5byqfw560n079v68qjgzh2brq2";
      extraPostFetch = ''
        #find . -maxdepth 1 -type d | sort
        rm -rf Python-2.7.13 benchmarks metrics py-yajl rfc gold web testdata services demo devtools cpp
        # find . -maxdepth 1 -type d | sort
      ''; # breakers: doc, pgen2
    };

    # src = stdenv.lib.cleanSourceWith {
    #   src = fetchFromGitHub {
    #     owner = "oilshell";
    #     repo = "oil";
    #     rev = "ea80cdad7ae1152a25bd2a30b87fe3c2ad32394a";
    #     sha256 = "0pxn0f8qbdman4gppx93zwml7s5byqfw560n079v68qjgzh2brq2";
    #   };
    #   filter = stdenv.lib.cleanSourceFilter;
    # };

    # src = stdenv.lib.sourceByRegex (fetchFromGitHub {
    #   owner = "oilshell";
    #   repo = "oil";
    #   rev = "ea80cdad7ae1152a25bd2a30b87fe3c2ad32394a";
    #   sha256 = "0pxn0f8qbdman4gppx93zwml7s5byqfw560n079v68qjgzh2brq2";
    # }) [".*"];

    # TODO: not sure why I'm having to set this for nix-build...
    #       can anyone tell if I'm doing something wrong?
    SOURCE_DATE_EPOCH=315532800;


    # These aren't, strictly speaking, nix/nixpkgs specific, but I've had hell
    # upstreaming them.
    patches = [
      ./0001-add_setup_py.patch
      ./0002-add_MANIFEST_in.patch
      ./0003-fix_codegen_shebang.patch
      ./0004-disable-internal-py-yajl-for-nix-built.patch
    ];

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

    LOCALE_ARCHIVE = stdenv.lib.optionalString (stdenv.buildPlatform.libc == "glibc") "${glibcLocales}/lib/locale/locale-archive";

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
