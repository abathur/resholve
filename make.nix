{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  # wordswurst = callPackage ../wordswurst { };
  wordswurst = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "wordswurst";
      rev = "d3e687a29751d3a087c21ff751746feeb9164711";
      hash = "sha256-dUrEzcf7EahrazWvLu4Yemh4ZTxxQRhcCbmLy6Y/LVk=";
    })
    { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff util-linux wordswurst sassc ];
}
