{ stdenv, lib, resholve, bash }:

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
      preFixup = ''
        pushd $out
        resholve --interpreter ${bash}/bin/bash --overwrite ${toString (flags ++ scripts)}
        popd
      '';
    }));
in lib.extendDerivation true passthru self
