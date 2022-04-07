{ stdenv, lib, resholve, resholve-utils }:

{ pname
, src
, version
, passthru ? { }
, solutions
, ...
}@attrs:
let
  inherit stdenv;

  /*
  Knock out our special solutions arg, but otherwise
  just build what the caller is giving us. We'll
  actually resholve it separately below (after we
  generate binlore for it).
  */
  unresholved = (stdenv.mkDerivation ((removeAttrs attrs [ "solutions" ])
    // {
    inherit pname version src;
  }));
in
/*
resholve in a separate derivation; some concerns:
- we aren't keeping many of the user's args, so they
  can't readily set LOGLEVEL and such...
- not sure how this affects multiple outputs
*/
lib.extendDerivation true passthru (stdenv.mkDerivation {
    src = unresholved;
    version = unresholved.version;
    pname = "resholved-${unresholved.pname}";
    buildInputs = [ resholve ];

    # retain a reference to the base
    passthru = unresholved.passthru // {
      unresholved = unresholved;
    };

    # do these imply that we should use NoCC or something?
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      cp -R $src $out
    '';

    # enable below for verbose debug info if needed
    # supports default python.logging levels
    # LOGLEVEL="INFO";
    /*
      subshell/PS4/set -x and : command to output resholve envs
      and invocation. Extra context makes it clearer what the
      Nix API is doing, makes nix-shell debugging easier, etc.
    */
    preFixup = ''
      (
        cd "$out"
        PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
        set -x
        : changing directory to $PWD
        ${builtins.concatStringsSep "\n" (resholve-utils.makeCommands solutions unresholved)}
      )
    '';
  })
