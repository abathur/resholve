{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  wordswurst = callPackage ../wordswurst { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff util-linux wordswurst ];
}
