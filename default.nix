{ pkgs ? import <nixpkgs> { }
, doCheck ? true
}:

with pkgs; rec
{
  resholve = callPackage ./resholve.nix { inherit doCheck; };
  resholvePackage =
    callPackage ./resholve-package.nix { inherit resholve; };
}
