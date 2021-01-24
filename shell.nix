/*
This shell is for using resholve--it builds and loads
resholve itself, not just resholve's dependencies.
*/
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholve = callPackage ./resholve.nix { doCheck = false; };
  resolveTimeDeps = [ file findutils gettext ];
  checkInputs = [ pkgs.bats ];
in
pkgs.mkShell {
  buildInputs = [ resholve bats nixpkgs-fmt ] ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
  INTERP = "${bash}/bin/bash";
}
