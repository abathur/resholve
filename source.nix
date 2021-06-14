{ fetchFromGitHub
, ...
}:

rec {
  version = "0.6.0-pre";
  rSrc =
    # local build -> `make ci`; `make clean` to restore
    # return to remote source
    if builtins.pathExists ./.local
    then ./.
    else
      fetchFromGitHub {
        owner = "abathur";
        repo = "resholve";
        rev = "6265e7c107b071eea6130aa7c9a9f0301bd9f7eb";
        hash = "sha256-PcNqLcScmmhr4BBkugx8vJdnhtWI7K/cX0MYAo1PVVc=";
        # rev = "v${version}";
        # hash = "sha256-+9MjvO1H+A3Ol2to5tWqdpNR7osQsYcbkX9avAqyrKw=";
      };
}
