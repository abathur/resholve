{ stdenv, lib, resholved, }:

{ pname, src, version, scripts, inputs ? [ ], allow ? { }, passthru ? { }, ...
}@attrs:
let
  inherit stdenv;
  self = (stdenv.mkDerivation ((removeAttrs attrs [ "script" "inputs" "allow" ])
    // {
      # wish I knew why I commented this out...
      inherit pname version src;
      buildInputs = [ resholved ];
      propagatedBuildInputs = inputs;
      RESHOLVE_PATH = "${lib.makeBinPath inputs}";
      RESHOLVE_ALLOW = toString
        (lib.mapAttrsToList (name: value: map (y: name + ":" + y) value) allow);
      #LOGLEVEL="INFO";
      buildPhase = ''
        runHook preBuild
        resholver ${toString scripts}
        runHook postBuild
      '';
    }));
in lib.extendDerivation true passthru self
