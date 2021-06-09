{ pkgs ? import <nixpkgs> { }, rSrc ? ./. }:

with pkgs;
let
  deps = pkgs.callPackage (rSrc + /deps.nix) { inherit rSrc; };
  inherit (callPackage ./default.nix { })
    resholve resholvePackage;
  inherit (callPackage ./test.nix {
    inherit resholve resholvePackage;
    inherit rSrc;
    inherit (deps) binlore;
    runDemo = true;
  })
    module1 module2 module3 cli;

in runCommand "resholve-ci" { } ''
  mkdir $out
  printf "\033[33m============================= resholve Nix demo ===============================\033[0m\n"
  env -i ${module3}/bin/conjure.sh |& tee nix-demo.ansi
  ${bat}/bin/bat --paging=never --color=always ${module3}/bin/conjure.sh ${module2}/bin/openssl.sh ${module1}/bin/libressl.sh |& tee -a nix-demo.ansi
  ${ansifilter}/bin/ansifilter -o $out/test.txt --text ${cli}/test.ansi
  ${ansifilter}/bin/ansifilter -o $out/demo.txt --text ${cli}/demo.ansi
  ${ansifilter}/bin/ansifilter -o $out/nix-demo.txt --text nix-demo.ansi
''
