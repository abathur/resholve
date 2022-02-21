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
      rev = "v0.1.4";
      hash = "sha256-+N0Bqyaj/mAwrcgFtUI8czmKo3VW6J8ZRxaPEghp7QM=";
    })
    { };
  # oil = callPackage ../oildev { };
  oil = callPackage
    (fetchFromGitHub {
      owner = "abathur";
      repo = "nix-py-dev-oil";
      rev = "v0.8.12.2";
      hash = "sha256-+dVxzPKMGNKFE+7Ggzx9iWjjvwW2Ow3UqmjjUud9Mqo=";
    })
    { };
}
