{ pkgs ? import <nixpkgs> { } }:

with pkgs; let
  source = callPackage ./source.nix { };
  deps = callPackage ./deps.nix { };
in
with pkgs; rec
{
  resholve = callPackage ./resholve.nix {
    inherit (source) rSrc;
    inherit (source) version;
    inherit (deps) binlore;
    inherit (deps.oil) oildev;
  };
  resholvePackage = callPackage ./resholve-package.nix {
    inherit resholve;
    inherit (deps) binlore;
  };
}
