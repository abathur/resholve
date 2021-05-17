{ lib
, callPackage
, python27Packages
, installShellFiles
, rSrc
, bash
, oildev
, binlore
}:
let
  version = "0.5.1";
  # rSrc = ./.;
in
python27Packages.buildPythonApplication {
  pname = "resholve";
  inherit version;
  src = rSrc;
  format = "other";

  nativeBuildInputs = [ installShellFiles ];

  propagatedBuildInputs = [ oildev python27Packages.ConfigArgParse ];

  patchPhase = ''
    for file in resholve; do
      substituteInPlace $file --subst-var-by version ${version}
    done
  '';

  installPhase = ''
    install -Dm755 resholve $out/bin/resholve
    installManPage resholve.1
  '';

  # Do not propagate Python; may be obsoleted by nixos/nixpkgs#102613
  # for context on why, see abathur/resholve#20
  postFixup = ''
    rm $out/nix-support/propagated-build-inputs
  '';

  meta = with lib; {
    description = "Resolve external shell-script dependencies";
    homepage = "https://github.com/abathur/resholve";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
    passthru.tests = callPackage (rSrc + /test.nix) { inherit rSrc; inherit binlore; };
  };
}
