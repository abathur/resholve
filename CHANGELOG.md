# Changelog

resholved is not yet versioned (though it will be in the near future). Until it is, I'll list major changes by date.

## Jun 28 2020
- Improved handling of aliases. This includes the ability to resolve simple commands inside an alias. This behavior is only active when `--resolve-aliases` is passed. (equivalent in Nix: `flags = [ "--resolve-aliases" ];`). There will probably eventually be an env option for this as well. 
- In order to implement alias handling, I significantly refactored the resolution code to give resholved the ability to handle different resolution contexts/scopes. I know this change has *fixed* some subtle edge cases, and the tests pass, but of course it's possible it has introduced some problems.
- Switch from travis-ci to gh actions.

## May 17 2020
- Detect and warn about first-word variables (i.e., variables run as commands). These may be an error at some point, but for now the warning just requests feedback.

## Apr  1 2020
- `--allow unresholved_inputs:commandname` to exempt a command from resolution.

## Mar 28 2020
- Rename `resholver.py` to `resholver`.

## Mar 27 2020
- Rename `SHELL_RUNTIME_DEPENDENCY_PATH` to `RESHOLVE_PATH`.
- Initially there was an --allow arg/env syntax that just generally exempted a token in all contexts. At this point I began breaking these out into types. So rather than using `--allow PWD` to permit `$PWD|${PWD}` anywhere dynamic values were checked, you might now specify `--allow source:PWD`. I also renamed the env equivalent from `ALLOWED_VARSUBS` to `RESHOLVE_ALLOW`.
- Reasonably complete Nix integration (the first point at which I could use resholved to build scripts into my shell profile). CI run includes a Nix-specific demonstration of this capability.
- Write "directives" at the end of resolved files to encode what should be exempt from further checking. These can be new directives from --allow/RESHOLVE_ALLOW, and executables/sources which were resolved to absolute paths in a previous run. These directives are necessary for resholved to resolve a script that sources another previously-resolved script while respecting the rules it was built with.

## Mar 15 2020
- Check builtins against hardcoded list (previously used Oil's builtin method).
- Return exit status.

## Feb 24 2020
Initial publication.
