{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # TODO: see extract_require_bats branch
    # bats-require = {
    #   url = "github:abathur/bats-require";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-utils.follows = "flake-utils";
    #   inputs.flake-compat.follows = "flake-compat";
    # };
    # obtuse name to avoid package/flake clash
    wwurst = {
      url = "github:abathur/wordswurst";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
    binlore = {
      url = "github:abathur/binlore";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  description = "Resolve external shell-script dependencies";

  outputs = { self, nixpkgs, flake-utils, flake-compat, /*bats-require,*/ wwurst, binlore }:
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
            # bats-require.overlays.default
            wwurst.overlays.default
            binlore.overlays.default
            self.overlays.default
          ];
        };
      in
        {
          # only ~exporting these for resholve-with-packages shenanigans
          _pkgs = pkgs;
          packages = {
            inherit (pkgs) resholve;
            default = pkgs.resholve;
            # support quick DIY resholving of a script from a set of nixpkgs
            # nix run .#resholve-with-packages -- <script-file> [<package>...]
            resholve-with-packages = (pkgs.writeScriptBin "resholve-with-packages" ''
              #!${pkgs.bash}/bin/bash

              if [ "$#" -lt 2 ]; then
                echo "usage: resholve-with-packages <script-file> [package…]" 1>&2
                exit 64
              fi

              readonly script="$1"
              shift

              dep_lore(){
                ${pkgs.nix}/bin/nix build --impure --print-out-paths -f -
              } <<EOF
              with (builtins.getFlake "${self}")._pkgs."${system}"; (binlore.collect { drvs = [ $@ ]; })
              EOF

              dep_path(){
                ${pkgs.nix}/bin/nix eval --impure --raw -f -
              } <<EOF
              with (builtins.getFlake "${self}")._pkgs."${system}"; (lib.makeBinPath [ $@ ])
              EOF

              export RESHOLVE_LORE="$(dep_lore "$@")"
              export RESHOLVE_PATH="$(dep_path "$@")"

              ${pkgs.resholve}/bin/resholve --interpreter ${pkgs.bash}/bin/bash < "$script"
            '');
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
          } // pkgs.lib.optionalAttrs (!(builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ])) {
            aarch64-cross-test = pkgs.pkgsCross.aarch64-multiplatform.lesspipe.override (old: {
              inherit (pkgs.pkgsCross.aarch64-multiplatform) resholve;
            });
          };
          devShells = let
            resolveTimeDeps = [ pkgs.bash pkgs.coreutils pkgs.file pkgs.findutils pkgs.gettext ];
          in {
            default = pkgs.mkShell {
              buildInputs = [ pkgs.bash pkgs.resholve pkgs.bats pkgs.man ];
              RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
              RESHOLVE_LORE = "${pkgs.binlore.collect { drvs = resolveTimeDeps; } }";
              INTERP = "${pkgs.bash}/bin/bash";
              shellHook = ''
                demo()(
                  cd ${pkgs.lib.cleanSource self}
                  ./demo
                )

                echo "
                This shell session is preconfigured with some environment variables
                needed to run resholve's CLI demo. This will be less magical if you
                see them first:

                $(declare -p RESHOLVE_PATH RESHOLVE_LORE)

                resholve enacts an explicit-is-better-than-implicit philosophy, so
                it makes you specify dependencies via arguments or environment vars.
                RESHOLVE_PATH includes packages used in the demo: bash, coreutils,
                file, find, and gettext. If you use this shell to resolve scripts
                with those utilities, it'll appear to automatically pick them up.
                If you use commands not in those packages, it'll complain.

                RESHOLVE_LORE specifies a directory with static analysis resholve
                uses to decide which commands are most likely to execute other
                commands passed to them as arguments. In this case, the analysis
                has been precomputed for the same packages in RESHOLVE_PATH.

                Test files used in the demo are in:
                ${pkgs.lib.cleanSource self}/tests

                Enter \`demo\` to run it, and \`man resholve\` for documentation.
                "
              '';
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
