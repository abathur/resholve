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
  #wordswurst = callPackage ../wordswurst { };
  wordswurst = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "wordswurst";
      rev = "df2b4873ea66d904bb863ee9f0e21be1ebaab9be";
      hash = "sha256-aN29FphL6Bh5ts/5/ydso5vVFeB/6b5hj+6fynvoYus=";
    })
    { };
in
pkgs.mkShell {
  buildInputs = [ resholve bats nixpkgs-fmt cloc wordswurst sassc scss-lint ];
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
  RESHOLVE_LORE = "${deps.binlore.collect { drvs = resolveTimeDeps; } }";
  INTERP = "${bash}/bin/bash";
}
