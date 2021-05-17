{ pkgs ? import <nixpkgs> { } }:

let
  rSrc = ./.;
  deps = pkgs.callPackage (rSrc + /deps.nix) { inherit rSrc; };
in with pkgs; rec
{
  resholve = callPackage (rSrc + /resholve.nix) {
    inherit rSrc;
    inherit (deps) binlore;
    inherit (deps.oil) oildev;
    # oildev = deps.oil.oildev;
  };
  resholvePackage = callPackage (rSrc + /resholve-package.nix) {
    inherit resholve;
    inherit (deps) binlore;
  };
}
