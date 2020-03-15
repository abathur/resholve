{ pkgs ? import (fetchTarball "channel:nixos-19.09") { } }:

let
  mine = with pkgs; rec {
    py-yajl = python27Packages.buildPythonPackage rec {
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

    oilPython = python27.withPackages (ps: with ps; [ six typing ]);

    oildev = python27Packages.buildPythonPackage rec {
      pname = "oil";
      version = "undefined";

      src = fetchFromGitHub {
        owner = "abathur";
        repo = "oil";
        rev = "259e582598689cb5077c44819f3234dda79c34fa";
        sha256 = "0rx68y8r82sr8qmbr806iaz2pispn02f64k6xywxpj5lx05jynlz";
      };

      buildInputs = [ oilPython readline re2c cmark py-yajl makeWrapper ];

      nativeBuildInputs = [ re2c file oilPython py-yajl ];

      # runtime deps
      propagatedBuildInputs = [ re2c oilPython py-yajl ];

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
        license = with lib.licenses; [
          psfl # Includes a portion of the python interpreter and standard library
          asl20 # Licence for Oil itself
        ];
      };
    };
    runtimeDeps = [ pkgs.file pkgs.gettext ];
  };

in pkgs.mkShell {
  buildInputs = [ mine.oildev ] ++ mine.runtimeDeps;
  SHELL_RUNTIME_DEPENDENCY_PATH = "${pkgs.lib.makeBinPath mine.runtimeDeps}";
}
