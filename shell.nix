# broken cutdown attempt
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  deps = callPackage ./deps.nix { };
  resolveTimeDeps = [ file gettext ];
  checkInputs = [ pkgs.bats ];
in pkgs.mkShell {
  buildInputs = [ deps.oildev ] ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
  shellHook = ''
    PATH="$PWD:$PATH"
  '';
}
