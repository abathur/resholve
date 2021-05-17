/*
This shell is for using resholve--it builds and loads
resholve itself, not just resholve's dependencies.
*/
{ pkgs ? import <nixpkgs> { }, rSrc ? ./. }:

with pkgs;
let
  deps = pkgs.callPackage (rSrc + /deps.nix) { inherit rSrc; };
  resholve = (callPackage ./default.nix { }).resholve;
  resolveTimeDeps = [ coreutils file findutils gettext ];
in
pkgs.mkShell {
  buildInputs = [ resholve bats nixpkgs-fmt ];
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
  RESHOLVE_LORE = "${deps.binlore.collect { drvs = resolveTimeDeps; } }";
  INTERP = "${bash}/bin/bash";
}
