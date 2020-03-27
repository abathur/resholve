{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholved = callPackage ./resholved.nix { };
  heh = resholved.penis;
  buildResholvedPackage =
    callPackage ./mk-resholved-derivation.nix { inherit resholved; };

in {
  inherit resholved;
  inherit buildResholvedPackage;
}
