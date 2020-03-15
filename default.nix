{ lib, fetchFromGitHub, stdenv, cmark, file, gettext, git,
  makeWrapper, runCommand, python27, re2c, readline }:
let
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

	oilPython = python27.withPackages (ps: with ps; [ six typing ]);

	oildev = python27.pkgs.buildPythonPackage rec {
		pname = "oil";
		version = "undefined";

		# src = builtins.fetchGit ../../../../work/oil;
		src = fetchFromGitHub {
			owner = "abathur";
			repo = "oil";
			rev = "259e582598689cb5077c44819f3234dda79c34fa";
			sha256 = "0rx68y8r82sr8qmbr806iaz2pispn02f64k6xywxpj5lx05jynlz";
		};

		# src = fetchFromGitHub {
    #   owner = "oilshell";
		#   repo = "oil";
		#   rev = "58f2372abd7df45221c0b74239cdc4442dbb8906";
		#   sha256 = "15qmkhkj7cc1kb0c42vshddmd484yi5x2xh4826i033drf3iqryw";
		#   fetchSubmodules = true;
		# };

		buildInputs = [ oilPython readline re2c cmark py-yajl makeWrapper ];
		# buildInputs = [ ];
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
	      patchShebangs .
			# substituteInPlace build/dev.sh --replace "native/libc_test.py" "# native/libc_test.py"
			# substituteInPlace build/codegen.sh --replace "re2c() { _deps/re2c-1.0.3/re2c" "# re2c() { _deps/re2c-1.0.3/re2c"

		'';

		makeWrapperArgs = ["--set _OVM_RESOURCE_ROOT $out/${oilPython.sitePackages}" ];

		postInstall = ''
			makeWrapper $out/bin/oil.py $out/bin/oil --add-flags oil
			makeWrapper $out/bin/oil.py $out/bin/osh --add-flags osh
		'';

		prePatch = ''
			substituteInPlace ./doctools/cmark.py --replace "/usr/local/lib/libcmark.so" "${cmark}/lib/libcmark${stdenv.hostPlatform.extensions.sharedLibrary}"
		'';

		meta = {
			description = "A new unix shell";
			homepage = https://www.oilshell.org/;
			license = with lib.licenses; [
				psfl # Includes a portion of the python interpreter and standard library
				asl20 # Licence for Oil itself
			];
		};

		passthru = {
			shellPath = "/bin/osh";
		};

	};
	runtimeDeps = [ oildev file gettext ];
in python27.pkgs.buildPythonApplication {
  name = "resholved";
  src = ./.;

  format = "other";

  propagatedBuildInputs = [
    oildev
  ];

  installPhase = ''
    mkdir -p $out/bin

    mv resholver.py $out/bin/resholver
    chmod +x $out/bin/resholver
  '';
}
