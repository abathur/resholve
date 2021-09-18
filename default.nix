{ pkgs ? import <nixpkgs> { } }:

with pkgs; let
  source = callPackage ./source.nix { };
  deps = callPackage ./deps.nix { };
in
with pkgs; rec
{
  resholve = callPackage ./resholve.nix {
    inherit (source) rSrc;
    inherit (source) version;
    inherit (deps) binlore;
    inherit (deps.oil) oildev;
  };
  resholve-utils = callPackage ./resholve-utils.nix {
    inherit resholve;
    inherit (deps) binlore;
  };
  resholvePackage = callPackage ./resholve-package.nix {
    inherit resholve;
    inherit resholve-utils;
  };
  resholveScript = name: partialSolution: body:
    writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${runtimeShell}
        ${body}'';
      checkPhase = ''
        (
          PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
          set -x
          ${resholve-utils.makeInvocation name (partialSolution // {
            scripts = [ "${placeholder "out"}" ];
            interpreter = "${runtimeShell}";
          })}
        )
        ${stdenv.shell} -n $out
      '';
    };
  # writeResholveBin "foo" { ... } '' echo "Hello" ''
  resholveScriptBin = name: partialSolution: body:
    writeTextFile rec {
      inherit name;
      executable = true;
      destination = "/bin/${name}";
      text = ''
        #!${runtimeShell}
        ${body}'';
      checkPhase = ''
        (
          cd "$out"
          PS4=$'\x1f'"\033[33m[resholve context]\033[0m "
          set -x
          : changing directory to $PWD
          ${resholve-utils.makeInvocation name (partialSolution // {
            scripts = [ "bin/${name}" ];
            interpreter = "${runtimeShell}";
          })}
        )
        ${stdenv.shell} -n $out/bin/${name}
      '';
    };
}
