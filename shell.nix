/*
This shell is for using resholved--it builds and loads
resholved itself, not just resholved's dependencies.
*/
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholved = callPackage ./default.nix { doCheck=false; };
  resolveTimeDeps = [ file gettext ];
  checkInputs = [ pkgs.bats ];
in pkgs.mkShell {
  buildInputs = [ resholved.resholved ] ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
}
