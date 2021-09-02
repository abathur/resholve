{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-rc.4";
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
        hash = "sha256-WWG3+wHQAAnw+62+IYeNdigOcGkgDezatbSwOI93pn8=";
      };
}
