{ pkgs ? import <nixpkgs> { }, source ? pkgs.callPackage ./source.nix { } }:

let
  deps = pkgs.callPackage ./deps.nix { };
  inherit (pkgs.callPackage ./default.nix { })
    resholve python27;
  inherit (pkgs.callPackage ./test.nix {
    inherit resholve;
    inherit (source) rSrc;
    inherit (deps) binlore;
    runDemo = true;
    inherit python27;
  })
    module1 module2 module3 cli resholvedScript resholvedScriptBin resholvedScriptBinNone;

in
pkgs.runCommand "resholve-ci" { } ''
  diff ${resholvedScript} ${resholvedScriptBin}/bin/resholved-script-bin
  bash ${resholvedScriptBinNone}/bin/resholved-script-bin
  mkdir $out
  printf "\033[33m============================= resholve Nix demo ===============================\033[0m\n"
  env -i ${module3}/bin/conjure.sh |& tee nix-demo.ansi
  ${pkgs.bat}/bin/bat --paging=never --color=always ${module3}/bin/conjure.sh ${module2}/bin/openssl.sh ${module1}/bin/libressl.sh |& tee -a nix-demo.ansi
  ${pkgs.ansifilter}/bin/ansifilter -o $out/test.txt --text ${cli}/test.ansi
  ${pkgs.ansifilter}/bin/ansifilter -o $out/demo.txt --text ${cli}/demo.ansi
  ${pkgs.ansifilter}/bin/ansifilter -o $out/nix-demo.txt --text nix-demo.ansi
''
