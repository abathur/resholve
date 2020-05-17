{
  pkgs ? import <nixpkgs> { },
  doCheck ? true
}:

with pkgs;
let
  resholved = callPackage ./resholved.nix { inherit doCheck; };
  buildResholvedPackage =
    callPackage ./mk-resholved-derivation.nix { inherit resholved; };

in {
  inherit resholved;
  inherit buildResholvedPackage;
}
