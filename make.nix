{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  # wordswurst = callPackage ../wordswurst { };
  wordswurst = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "wordswurst";
      rev = "66763c5f46cda53d6244383b1322d2699affe167";
      hash = "sha256-d3ieqsYPNghCsid8WcW3z4wqQbtEFOu6kb8j8mxPuc4=";
    })
    { };
in
pkgs.mkShell {
  buildInputs = [ nix coreutils gnused groff util-linux wordswurst sassc ];
}
