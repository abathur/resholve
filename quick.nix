{ pkgs ? import <nixpkgs> { }, source ? pkgs.callPackage ./source.nix { } }:

with pkgs;
let
  deps = pkgs.callPackage ./deps.nix { };
  inherit (callPackage ./default.nix { })
    resholve resholvePackage;
  inherit (callPackage ./test.nix {
    inherit resholve resholvePackage;
    inherit (source) rSrc;
    inherit (deps) binlore;
    runDemo = false;
  })
    cli;

in
cli
