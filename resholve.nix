{ stdenv
, callPackage
, python27Packages
, installShellFiles
, file
, findutils
, gettext
, bats
, bash
, doCheck ? true
}:
let
  version = "0.3.0";
  rSrc = ./.;
  deps = callPackage ./deps.nix {
    /*
    resholve needs to patch Oil, but trying to avoid adding
    them all *to* nixpkgs, since they aren't specific to
    nix/nixpkgs.
    */
    oilPatches = [
      "${rSrc}/0001-add_setup_py.patch"
      "${rSrc}/0002-add_MANIFEST_in.patch"
      "${rSrc}/0003-fix_codegen_shebang.patch"
      "${rSrc}/0004-disable-internal-py-yajl-for-nix-built.patch"
    ];
  };
  resolveTimeDeps = [ file findutils gettext ];
in
python27Packages.buildPythonApplication {
  pname = "resholve";
  inherit version;
  src = rSrc;
  format = "other";
  disabled = !python27Packages.isPy27;

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [ deps.oildev python27Packages.ConfigArgParse ];

  patchPhase = ''
    for file in resholve; do
      substituteInPlace $file --subst-var-by version ${version}
    done
  '';

  installPhase = ''
    mkdir -p $out/bin
    install resholve $out/bin/
    installManPage resholve.1
  '';
  inherit doCheck;
  checkInputs = [ bats ];
  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";

  # explicit interpreter for test suite; maybe some better way...
  INTERP = "${bash}/bin/bash";
  checkPhase = ''
    PATH=$out/bin:$PATH
    patchShebangs .
    ./test.sh
  '';

  meta = {
    description = "Resolve external shell-script dependencies";
    homepage = "https://github.com/abathur/resholve";
    license = with stdenv.lib.licenses; [
      mit
    ];
    maintainers = with stdenv.lib.maintainers; [ abathur ];
    platforms = stdenv.lib.platforms.all;
  };
}
