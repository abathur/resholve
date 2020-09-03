{ stdenv, lib, resholve, }:

{ pname, src, version, scripts, inputs ? [ ], allow ? { }, flags ? [ ], passthru ? { }, ...
}@attrs:
let
  inherit stdenv;
  self = (stdenv.mkDerivation ((removeAttrs attrs [ "script" "inputs" "allow" "flags" ])
    // {
      inherit pname version src;
      buildInputs = [ resholve ];
      RESHOLVE_PATH = "${lib.makeBinPath inputs}";
      RESHOLVE_ALLOW = toString
        (lib.mapAttrsToList (name: value: map (y: name + ":" + y) value) allow);
      #LOGLEVEL="INFO";
      buildPhase = ''
        runHook preBuild
        resholve ${toString (flags ++ scripts)}
        runHook postBuild
      '';
    }));
in lib.extendDerivation true passthru self
