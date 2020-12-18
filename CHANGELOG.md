# Changelog

## v0.2.0 (Dec 17 2020)
- add `--inputs` and `RESHOLVE_INPUTS` as aliases of `--path`
  and `RESHOLVE_PATH`
- add a plaintext copy of the manpage as stopgap documentation
  and update README

## v0.1.1 (Dec 14 2020)
Add actual code support for --prologue --epilogue, which were accidentally left out of v0.1.0

## v0.1.0 (Dec 14 2020)
- flags renamed/restructured
    - tasks from `--allow` are now split out over `--keep` (the closest analogue to allow), `--fix`, and `--fake`
    - "fake" directives instruct resholve to pretend some entities are defined if it can't locate them in the code (i.e., they come from another file, or are defined in eval-ed code.) This type subsumes the --allow alias/builtin/function/unresholved_inputs:name pattern(s).
    - added a manpage documenting these flags
- Nix API updated to track this (though there are some rough edges here that may beg for further iteration...)
- it is now possible to instruct resholve to treat an absolute path as if it were a bare command (and thus resolve it) with `--fix /absolute/path`
- more-consistent support for env-var equivalents to CLI arguments (generally, RESHOLVE_argname)
- in-file-directive format updated (backwards-incompatible)
- no longer merges directives in an environment variable with those provided in a flag. background: 
    - resholve has a general pattern of liberally merging directives from multiple sources: ENV, space-separated in a single quoted flag argument, accumulated from multiple uses of the flag, and from in-document directives if present. 
    - resholve is adopting an argument-parsing module (configargparse) which does not use the environment variable if the flag is used. I'd rather not row against it, so I'm dropping this support (but I'm open to reconsidering it if there's a compelling argument made later).
- no longer raises a feedback warning for first-word variables (variables run as commands, or executables with a path-prefix variable).
    - it now raises an error
    - this error can be silenced with --keep '$variable' (implementing this feature is what un-blocks the change, which I've wanted to do for a bit)
    - this fix is a short-term compromise; a principled solution to this issue will be more-complex: resolving the variable itself. But, this is a real issue, and I think this incremental step is a material improvement.

Before this point resholve was not versioned; major changes by date.

## Dec 10 2020
This update marks the start of a period (*hopefully a short one*) with many breaking API changes. I am trying to get a few partially-finished features into the codebase, and will then be largely reworking the flag names before finally tagging an initial 0.1.0 release.
- *BREAKING*: Improved handling of single packages with multiple scripts (such as submodules.) 
    - At least for now, all of the scripts you want to resolve should be passed (in the Nix api as `scripts`, and as final arguments on the command line).
    - In order to make this work, I did need to shift the Nix API to run after the files were already in their final locations--during fixup phase (currently as preFixup). Before this change, `scripts` would be a list of filenames relative to the build, but it is now relative to $out.

    If you had something like `scripts = [ "openssl.sh" ];` to resolve a script before installing it to `$out/bin/openssl.sh` the updated form is: `scripts = [ "bin/openssl.sh" ];`
- *BREAKING*: resholve is now "handling" the interpreter/shebang. Since resholve doesn't actually understand your shebang, this takes a fairly explicit/declarative/idempotent approach. You now *must* specify an `--interpreter`, which may be
    - a path, in which case any existing shebang will be stripped and a shebang pointing to only this interpreter added
    - the magic string 'none', in which case any existing shebang will be stripped and nothing will replace it
- Made the decision to overwrite a script or not explicit via the `--overwrite` flag (when passed as a path). 
    - Before, resholve would only overwrite the script when it looked like it was running in a Nix build environment.
    - The Nix `resholvePackage` function takes care of passing this option, so it should be transparent if you're using the Nix API.

## Sep 2 2020
Rename resholved -> resholve (and resholver -> resholve)

## Jun 28 2020
- Improved handling of aliases. This includes the ability to resolve simple commands inside an alias. This behavior is only active when `--resolve-aliases` is passed. (equivalent in Nix: `flags = [ "--resolve-aliases" ];`). There will probably eventually be an env option for this as well. 
- In order to implement alias handling, I significantly refactored the resolution code to give resholve the ability to handle different resolution contexts/scopes. I know this change has *fixed* some subtle edge cases, and the tests pass, but of course it's possible it has introduced some problems.
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
- Reasonably complete Nix integration (the first point at which I could use resholve to build scripts into my shell profile). CI run includes a Nix-specific demonstration of this capability.
- Write "directives" at the end of resolved files to encode what should be exempt from further checking. These can be new directives from --allow/RESHOLVE_ALLOW, and executables/sources which were resolved to absolute paths in a previous run. These directives are necessary for resholve to resolve a script that sources another previously-resolved script while respecting the rules it was built with.

## Mar 15 2020
- Check builtins against hardcoded list (previously used Oil's builtin method).
- Return exit status.

## Feb 24 2020
Initial publication.
