{ callPackage
, fetchFromGitHub
}:

/*
  Notes on specific dependencies:
  - if/when python2.7 is removed from nixpkgs, this may need to figure
  out how to build oil's vendored python2
  - I'm not sure if glibcLocales is worth the addition here. It's to fix
  a libc test oil runs. My oil fork just disabled the libc tests, but
  I haven't quite decided if that's the right long-term call, so I
  didn't add a patch for it here yet.
*/

rec {
  # binlore = callPackage ../binlore { };
  binlore = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "binlore";
      rev = "v0.1.0";
      hash = "sha256-seTBOySCeOTfLR3VSla5fKE13rVla/VkxF6HRoxZfo8=";
    })
    { };
  # oil = callPackage ../oildev { };
  oil = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "nix-py-dev-oil";
      rev = "v0.8.12";
      hash = "sha256-/EvwxL201lGsioL0lIhzM8VTghe6FuVbc3PBJgY8c8E=";
    })
    { };
}
