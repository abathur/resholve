{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-rc.5";
  rSrc =
    # local build -> `make ci`; `make clean` to restore
    # return to remote source
    if builtins.pathExists ./.local
    then ./.
    else
      fetchFromGitHub {
        owner = "abathur";
        repo = "resholve";
        rev = "v${version}";
        hash = "sha256-n7l2vTYEw7ehSQ9wW1Stux3seLrpKtVKg9xCEMpykR4=";
      };
}
