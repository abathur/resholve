{ stdenv, callPackage, file, gettext, python27, bats }:
let
  deps = callPackage ./deps.nix { };
  resolveTimeDeps = [ file gettext ];
in python27.pkgs.buildPythonApplication {
  pname = "resholved";
  version = "unreleased";
  src = ./.;

  format = "other";

  propagatedBuildInputs = [ deps.oildev ];

  installPhase = ''
    mkdir -p $out/bin
    install resholver $out/bin/
  '';
  doCheck = true;
  checkInputs = [ bats ];
  RESHOLVE_PATH = "${stdenv.lib.makeBinPath resolveTimeDeps}";
  checkPhase = ''
    PATH=$out/bin:$PATH
    bats tests
  '';

  meta = {
    description = "Resolve external shell-script dependencies";
    homepage = "https://github.com/abathur/resholved";
    license = with stdenv.lib.licenses; [
      mit
    ];
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
