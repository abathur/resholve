/*
This shell is for using resholve--it builds and loads
resholve itself, not just resholve's dependencies.
*/
{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  resholve = callPackage ./default.nix { doCheck = false; };
  resolveTimeDeps = [ file findutils gettext ];
  checkInputs = [ pkgs.bats ];
  wavm = stdenv.mkDerivation rec {
    pname = "wavm";
    version = "unreleased";
    sourceRoot = "${src.name}/re2c";
    src = fetchFromGitHub {
      owner = "wavm";
      repo = "wavm";
      rev = "e289ba654fe51655ab080819fd85ed9c936aae6e";
      sha256 = "1grx7nl9fwcn880v5ssjljhcb9c5p2a6xpwil7zxpmv0rwnr3yqi";
    };
    buildInputs = [ pkgs.llvm_9 ];
    # nativeBuildInputs = [ autoreconfHook ];
    # preCheck = ''
    #   patchShebangs run_tests.sh
    # '';
  };
  test_bash = pkgs.bash_5.overrideAttrs (oldAttrs:
    with pkgs; rec {
      # borrowed from https://github.com/NixOS/nixpkgs/blob/master/pkgs/shells/bash/4.4.nix
      # except to skip external readline in favor of built-in readline
      patches = [ ];
      name = "auditbash";
      src = ../bash;
      # configureFlags =
      #   lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      #     "bash_cv_job_control_missing=nomissing"
      #     "bash_cv_sys_named_pipes=nomissing"
      #     "bash_cv_getcwd_malloc=yes"
      #   ] ++ lib.optionals stdenv.hostPlatform.isCygwin [
      #     "--without-libintl-prefix"
      #     "--without-libiconv-prefix"
      #     "--enable-readline"
      #     "bash_cv_dev_stdin=present"
      #     "bash_cv_dev_fd=standard"
      #     "bash_cv_termcap_lib=libncurses"
      #   ] ++ lib.optionals (stdenv.hostPlatform.libc == "musl") [
      #     "--without-bash-malloc"
      #     "--disable-nls"
      #   ];
      outputs = [ "out" ];
    });
in
pkgs.mkShell {
  buildInputs = [ resholve.resholve bats pythonPackages.ansi2html nixpkgs-fmt nixfmt ] ++ checkInputs;
  RESHOLVE_PATH = "${pkgs.lib.makeBinPath resolveTimeDeps}";
}
