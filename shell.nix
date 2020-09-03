/*
This shell is for using resholve--it builds and loads
resholve itself, not just resholve's dependencies.
*/
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholve = callPackage ./default.nix { doCheck=false; };
  resolveTimeDeps = [ file findutils gettext ];
  checkInputs = [ pkgs.bats ];
in pkgs.mkShell {
  buildInputs = [ resholve.resholve ] ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
}
