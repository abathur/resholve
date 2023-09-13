{ lib
, pkgs
, pkgsBuildHost
, version ? "0.9.0"
, rSrc ? pkgs.fetchFromGitHub {
    owner = "abathur";
    repo = "resholve";
    rev = "v${version}";
    hash = "sha256-FRdCeeC2c3bMEXekEyilgW0PwFfUWGstZ5mXdmRPM5w=";
  }
}:

let
  removeKnownVulnerabilities = pkg: pkg.overrideAttrs (old: {
    meta = (old.meta or { }) // { knownVulnerabilities = [ ]; };
  });
  # We are removing `meta.knownVulnerabilities` from `python27`,
  # and setting it in `resholve` itself.
  python27' = (removeKnownVulnerabilities pkgsBuildHost.python27).override {
    self = python27';
    pkgsBuildHost = pkgsBuildHost // { python27 = python27'; };
    # strip down that python version as much as possible
    openssl = null;
    bzip2 = null;
    readline = null;
    ncurses = null;
    gdbm = null;
    sqlite = null;
    rebuildBytecode = false;
    stripBytecode = true;
    strip2to3 = true;
    stripConfig = true;
    stripIdlelib = true;
    stripTests = true;
    enableOptimizations = false;
  };
  callPackage = lib.callPackageWith (pkgs // { python27 = python27'; });
  deps = callPackage ./deps.nix { };
in
rec {
  # not exposed in all-packages
  resholveBuildTimeOnly = removeKnownVulnerabilities resholve;
  # resholve itself
  resholve = removeKnownVulnerabilities (callPackage ./resholve.nix {
    inherit rSrc version resholve-utils;
    inherit (deps.oil) oildev;
    inherit (deps) configargparse;
    # used only in tests
    resholve = resholveBuildTimeOnly;
  });
  # funcs to validate and phrase invocations of resholve
  # and use those invocations to build packages
  resholve-utils = callPackage ./resholve-utils.nix {
    # we can still use resholve-utils without triggering a security warn
    # this is safe since we will only use `resholve` at build time
    resholve = resholveBuildTimeOnly;
  };
}
