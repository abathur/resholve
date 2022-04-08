{ pkgs ? import <nixpkgs> { } }:

with pkgs; let
  source = callPackage ./source.nix { };
  deps = callPackage ./deps.nix { };
in
with pkgs; rec
{
  # resholve itself
  resholve = callPackage ./resholve.nix {
    inherit (source) rSrc version;
    inherit (deps) binlore;
    inherit (deps.oil) oildev;
    inherit resholve-utils;
  };
  # funcs to validate and phrase invocations of resholve
  # and use those invocations to build packages
  resholve-utils = callPackage ./resholve-utils.nix {
    inherit resholve;
    inherit (deps) binlore;
  };
}
