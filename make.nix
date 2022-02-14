{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  # wordswurst = callPackage ../wordswurst { };
  wordswurst = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "wordswurst";
      rev = "df2b4873ea66d904bb863ee9f0e21be1ebaab9be";
      hash = "sha256-aN29FphL6Bh5ts/5/ydso5vVFeB/6b5hj+6fynvoYus=";
    })
    { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff util-linux wordswurst sassc ];
}
