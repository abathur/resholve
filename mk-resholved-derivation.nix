{ stdenv, lib, resholved, }:

{ pname, src, version, scripts, inputs ? [ ], allow ? { }, flags ? [ ], passthru ? { }, ...
}@attrs:
let
  inherit stdenv;
  self = (stdenv.mkDerivation ((removeAttrs attrs [ "script" "inputs" "allow" "flags" ])
    // {
      inherit pname version src;
      buildInputs = [ resholved ];
      # tentatively disabled because gc probably knows things I don't :)
      # propagatedBuildInputs = inputs;
      RESHOLVE_PATH = "${lib.makeBinPath inputs}";
      RESHOLVE_ALLOW = toString
        (lib.mapAttrsToList (name: value: map (y: name + ":" + y) value) allow);
      #LOGLEVEL="INFO";
      buildPhase = ''
        set -x
        runHook preBuild
        resholver ${toString (flags ++ scripts)}
        runHook postBuild
        set +x
      '';
    }));
in lib.extendDerivation true passthru self
