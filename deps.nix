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

    # TODO: this is a lie; pytest and pytest-shell are *my* (checkInput) dependencies, not oil's; but when I include them in the right location, I'm getting a duplicate copy of six in closure:
    #   Found duplicated packages in closure for dependency 'six':
    #   six 1.12.0 (/nix/store/lfy5lad891m1zcl0qr6c0igxky0ybgmn-python2.7-six-1.12.0/lib/python2.7/site-packages)
    #   six 1.12.0 (/nix/store/06kgcmn8mby0w78xp3h1ds2lh3y93r22-python-2.7.17-env/lib/python2.7/site-packages)

    # Package duplicates found in closure, see above. Usually this happens if two packages depend on different version of the same dependency.
    # builder for '/nix/store/gka72kwls8fc9l9ilxblyvw54rh5cys7-resholved.drv' failed with exit code 1
    # error: build of '/nix/store/gka72kwls8fc9l9ilxblyvw54rh5cys7-resholved.drv' failed
    # For now my goal is just getting the code under test; I suspect someone with more python packaging experience will know what I "should" do.
    # oilPython = python27.withPackages (ps: with ps; [ six typing pytest pytest-shell ]);
    buildInputs = with python27.pkgs;
      [ six typing pytest pytest-shell2 ]
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

  # TODO: could deduplicate this by putting the pytest stuff all in one spot
  #       and passing in the right python depending on use site.
  pytest-shell2 = python27.pkgs.buildPythonPackage {
    name = "pytest-shell-0.2.3";
    src = fetchurl {
      url =
        "https://files.pythonhosted.org/packages/ad/ae/7f4dfcab9b74e272674315f4b9141185d2a9072569fa334dd1facebb2234/pytest-shell-0.2.3.tar.gz";
      sha256 =
        "535178a527450371defbc00e542511300b6a8e3199abe537b31aae6eb3c94ded";
    };
    buildInputs = [ ];
    propagatedBuildInputs = [ python27.pkgs.pytest ];
    meta = {
      homepage = "https://hg.sr.ht/~danmur/pytest-shell";
      license = stdenv.lib.licenses.mit;
      description = "Pytest plugin for running shell commands/scripts.";
    };
  };

  pytest-shell3 = python37.pkgs.buildPythonPackage {
    name = "pytest-shell-0.2.3";
    src = fetchurl {
      url =
        "https://files.pythonhosted.org/packages/ad/ae/7f4dfcab9b74e272674315f4b9141185d2a9072569fa334dd1facebb2234/pytest-shell-0.2.3.tar.gz";
      sha256 =
        "535178a527450371defbc00e542511300b6a8e3199abe537b31aae6eb3c94ded";
    };
    buildInputs = [ ];
    propagatedBuildInputs = [ python37.pkgs.pytest ];
    meta = {
      homepage = "https://hg.sr.ht/~danmur/pytest-shell";
      license = stdenv.lib.licenses.mit;
      description = "Pytest plugin for running shell commands/scripts.";
    };
  };

  testPy = python37.withPackages (ps: with ps; [ pytest pytest-shell ]);
}
