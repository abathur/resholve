/*
  This shell is for using resholve--it builds and loads
  resholve itself, not just resholve's dependencies.
*/
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  deps = callPackage ./deps.nix { };
  resholve = (callPackage ./default.nix { }).resholve;
  resolveTimeDeps = [ coreutils file findutils gettext ];
  wordswurst = callPackage ../wordswurst { };
in
pkgs.mkShell {
  buildInputs = [ resholve bats nixpkgs-fmt cloc wordswurst sassc scss-lint ];
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
  RESHOLVE_LORE = "${deps.binlore.collect { drvs = resolveTimeDeps; } }";
  INTERP = "${bash}/bin/bash";
}
