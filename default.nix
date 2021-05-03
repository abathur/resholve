{ pkgs ? import <nixpkgs> { }
, doCheck ? true
}:

let
  # binlore = pkgs.callPackage ../binlore { };
  binlore = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "abathur";
    repo = "binlore";
    rev = "73db2f951d7318a9a401583445b737728d52153e";
    hash = "sha256-puUiXxmdV31Mh1MQmFdT+ukv4hkNujavMui2U46hYd8=";
  }) { };
in with pkgs; rec
{
  resholve = callPackage ./resholve.nix { inherit doCheck; };
  resholvePackage =
    callPackage ./resholve-package.nix { inherit resholve; inherit binlore; };
}
