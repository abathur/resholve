{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0";
  rSrc =
    # local build -> `make ci`; `make clean` to restore
    # return to remote source
    if builtins.pathExists ./.local
    then ./.
    else
      fetchFromGitHub {
        owner = "abathur";
        repo = "resholve";
        # rev = "v${version}";
        rev = "1e98669761ecb0d0741a6da0f73c8988b3b5497d";
        hash = "sha256-hkXLKvaeoURKLghzgMrbl5hJpCSn3MFzV1wmlYWAcn0=";
      };
}
