{ pkgs ? import <nixpkgs> { }
, doCheck ? true
}:

with pkgs;
let
  resholve = callPackage ./resholve.nix { inherit doCheck; };
  # intended long-term api
  # flags = [];
  # inputs = [];
  # prologue = file;
  # epilogue = file;
  # scripts = [];
  # fake = {};
  # fix = {};
  # keep = {};
  # builtins = [];
  # faff = 5;
  resholvePackage =
    callPackage ./resholve-package.nix { inherit resholve; };

in
{
  inherit resholve;
  inherit resholvePackage;
}
