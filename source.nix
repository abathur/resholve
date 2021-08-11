{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-rc.1";
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
        hash = "sha256-3/aGtGP3YgxZbdyUYS7jBuVixalBBQMFCX5a8SfhhYM=";
      };
}
