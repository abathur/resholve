{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  wordswurst = import ./wordswurst.nix { };
in
pkgs.mkShell {

  buildInputs = [
    nix
    coreutils
    gnused
    groff
    ansifilter
    wordswurst
    sassc
    # TODO: lint/format stuff? or do you want this in a dev shell once you convert to flake?
    # nixpkgs-fmt
    # scss-lint
  ];
}
