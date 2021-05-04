{ pkgs ? import <nixpkgs> { }
, doCheck ? true
}:

let
  # binlore = pkgs.callPackage ../binlore { };
  binlore = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "abathur";
    repo = "binlore";
    rev = "7c9fa9f2710bd4f2919ef2be46f8dd745eec8cec";
    hash = "sha256-ZKOPxVNfSyoSYqQydYP5vxG0BrE3gRNFGc65/VzOrBg=";
  }) { };
in with pkgs; rec
{
  resholve = callPackage ./resholve.nix { inherit doCheck; };
  resholvePackage =
    callPackage ./resholve-package.nix { inherit resholve; inherit binlore; };
}
