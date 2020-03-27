# broken cutdown attempt
{ pkgs ? import <nixpkgs> {} }:

with pkgs; let
  deps = callPackage ./deps.nix {};
  resolveTimeDeps = [ file gettext ];
  checkInputs = with python27.pkgs; [ six typing pytest deps.pytest-shell2 ];
in pkgs.mkShell {
  buildInputs = [ deps.oildev ] ++ resolveTimeDeps ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
}
