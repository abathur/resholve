{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    bats-require = {
      url = "github:abathur/bats-require";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    # obtuse name to avoid package/flake clash
    wwurst = {
      url = "github:abathur/wordswurst/flakify";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    binlore = {
      url = "github:abathur/binlore/flakify";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  description = "Resolve external shell-script dependencies";

  outputs = { self, nixpkgs, flake-utils, flake-compat, bats-require, wwurst, binlore }:
    {
      # TODO:
      # - document if I need nixpkgs.lib.composeExtensions wwurst.overlays.default or not. TL;DR: make sure you aren't holding this wrong or cargo culting
      # - update other flakes based on this?
      overlays.default = (final: prev: {
        inherit (prev.callPackage ./nixpkgs {
          version = prev.resholve.version + "-" + (self.shortRev or "dirty");
          rSrc = final.lib.cleanSource self;
        }) resholve;
      });
      nixpkgs_source = nixpkgs.outPath;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            bats-require.overlays.default
            wwurst.overlays.default
            binlore.overlays.default
            self.overlays.default
          ];
        };
      in
        {
          packages = {
            inherit (pkgs) resholve;
            default = pkgs.resholve;
            ci = let
              inherit (pkgs.resholve.tests.override(prev: { runDemo = true; })) module1 module2 module3 cli resholvedScript resholvedScriptBin resholvedScriptBinNone;
            in pkgs.runCommand "resholve-ci" { } ''
              diff ${resholvedScript} ${resholvedScriptBin}/bin/resholved-script-bin
              bash ${resholvedScriptBinNone}/bin/resholved-script-bin
              mkdir $out
              printf "\033[33m============================= resholve Nix demo ===============================\033[0m\n"
              env -i ${module3}/bin/conjure.sh |& tee nix-demo.ansi
              ${pkgs.bat}/bin/bat --paging=never --color=always ${module3}/bin/conjure.sh ${module2}/bin/openssl.sh ${module1}/bin/libressl.sh |& tee -a nix-demo.ansi
              ${pkgs.ansifilter}/bin/ansifilter -o $out/test.txt --text ${cli}/test.ansi
              ${pkgs.ansifilter}/bin/ansifilter -o $out/demo.txt --text ${cli}/demo.ansi
              ${pkgs.ansifilter}/bin/ansifilter -o $out/nix-demo.txt --text nix-demo.ansi
            '';
          };
          checks = pkgs.callPackages nixpkgs/test.nix {
            inherit (pkgs) resholve;
            rSrc = pkgs.lib.cleanSource self;
          };
          devShells = let
            resolveTimeDeps = [ pkgs.bash pkgs.coreutils pkgs.file pkgs.findutils pkgs.gettext ];
          in {
            default = pkgs.mkShell {
              buildInputs = [ pkgs.bash pkgs.resholve pkgs.bats ];
              RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
              RESHOLVE_LORE = "${pkgs.binlore.collect { drvs = resolveTimeDeps; } }";
              INTERP = "${pkgs.bash}/bin/bash";
            };
            make = pkgs.mkShell {
              makeInputs = with pkgs; lib.makeBinPath [
                git
                bash
                nix
                coreutils
                gnused
                groff
                ansifilter
                wordswurst
                sassc
                # TODO: lint/format stuff? or do you want this in a dev shell once you convert to flake?
                # nixpkgs-fmt
                # scss-lint
              ];
            };
          };
        }
    );
}
