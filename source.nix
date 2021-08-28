{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-rc.3";
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
        hash = "sha256-X4eu/K9qPsHHg5X6mxD8CLf806mL5EkJtj6NMD+zaPU=";
      };
}
