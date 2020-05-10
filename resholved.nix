{ stdenv, callPackage, file, gettext, python27, bats }:
let
  rSrc = ./.;
  deps = callPackage ./deps.nix {
    /*
    Resholved needs to patch Oil, but trying to avoid adding
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
  resolveTimeDeps = [ file gettext ];
in python27.pkgs.buildPythonApplication {
  pname = "resholved";
  version = "unreleased";
  src = rSrc;
  format = "other";

  propagatedBuildInputs = [ deps.oildev ];

  # TODO: try install -Dt $out/bin $src/yadm
  installPhase = ''
    mkdir -p $out/bin
    install resholver $out/bin/
  '';
  doCheck = true;
  checkInputs = [ bats ];
  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";
  checkPhase = ''
    PATH=$out/bin:$PATH
    ./test.sh
  '';

  meta = {
    description = "Resolve external shell-script dependencies";
    homepage = "https://github.com/abathur/resholved";
    license = with stdenv.lib.licenses; [
      mit
    ];
    maintainers = with stdenv.lib.maintainers; [ abathur ];
    platforms = stdenv.lib.platforms.all;
  };
}
