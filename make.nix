{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  wordswurst = import ./wordswurst.nix { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff ansifilter wordswurst sassc ];
}
