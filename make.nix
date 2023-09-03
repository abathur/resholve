{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  wordswurst = import ./wordswurst.nix { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff util-linux wordswurst sassc ];
}
