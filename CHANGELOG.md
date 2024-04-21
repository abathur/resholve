# Changelog

## v0.10.5 (Apr 21 2024)
- Warn instead of block on parse errors from sedparse.
- Track nix README changes made in nixpkgs.
- Expand passthru tests (all resholve-using packages in nixpkgs)

## v0.10.4 (Apr 13 2024)
Work around some test breaks coming in bats 1.11 while remaining compatible with 1.10. (No behavior changes in resholve itself.)

## v0.10.3 (Apr 13 2024)
~Work around some test breaks coming in bats 1.11 while remaining compatible with 1.10. (No behavior changes in resholve itself.)~

Don't use this release. It contains the same changes as 0.10.4, but I inadvertently included the changelog in a commit intended to be used as a patch (presence of the changelog makes it hard to apply against arbitrary versions).

## v0.10.2 (Mar 22 2024)
- Fix some cases where resholve could fail to find a node's first span_id.
- Ongoing cross oriented fixes exposed by xdg-utils getting resholved:
    - Swap out use of `awk` executable for dumb string searches and convert from an error to a warning.

## v0.10.1 (Mar 22 2024)
- Refactor to minimize cross changes. (Trying to land this in nixpkgs made me a little more confident about the best approach.)

## v0.10.0 (Mar 20 2024)
- Track fixes upstream in nixpkgs.
- Disable oildev libc tests. (These already caused trouble on macOS, but they also cause trouble with musl.)
- Update oil/OSH from v0.14 to v0.20 (a decent amount of refactoring to track, especially around exceptions).
- Fix ~parse errors caused by skipping grammar setup (#114).
- A number of cross oriented fixes exposed by xdg-utils getting resholved:
    - Use nixpgks version of re2c with oil instead of oil's specific version.
    - Swap out use of `sed` executable for `sedparse`.
    - Use pkgsBuildBuild (not sure this is ideal, but it's okay to iterate and review should shake this loose).

## v0.9.1 (Nov 28 2023)
- Fix problem with handling of abspaths that share a name with a builtin (#111)

## September 14, 2023
Refactor Nix expressions and convert to flake.

## v0.9.0 (Jan 29 2023)
Update oil/osh parser from 0.8.12 -> 0.14.0. In the process of updating the parser, I also cut out some extensions and dependencies that resholve shouldn't need to depend on.

This release shouldn't include any substantive change in resholve itself, but I think it's prudent to signal the potential for regressions or new problems.

## v0.8.5 (Jan 17 2023)
- Fix problem with identical invocations beyond the first going unresolved in some contexts. (#94)

## v0.8.4 (Dec 19 2022)
- Add prologue/epilogue to more than first script arg (#89)

## v0.8.3 (Nov 27 2022)
- Include missed manpage update for v0.8.2

## v0.8.2 (Nov 27 2022)
- Add `--fix <command>` form to circumvent NAUGHTY_NIXERS.

## v0.8.1 (Jul 31 2022)
- Fix missing duration arg for `timeout` command parser
- Fix nix `writeScript*` fns when interpreter is `none`
- Improve message when command parsers fail (suggested in #82)
- Fix `-vvarname value` handling in the `awk` command parser (#82)

## v0.8.0 (April 8 2022)
This release ~completely reorganizes the Nix API and introduces a new function. The renames are:
- `resholvePackage` -> `resholve.mkDerivation`
- `resholveScript` -> `resholve.writeScript`
- `resholveScriptBin` -> `resholve.writeScriptBin`

The new function is `resholve.phraseSolution`. It's a
little like `resholve.writeScript` in that it works on
a single solution--but it only generates the invocation
that you need to run resholve as part of a build. This
makes it easier to bolt resholve on to other types of
Nix builds.

## v0.7.0 (April 8 2022)
This release sands down a few real-world shortcomings exposed by
a mix of user reports and my own experience resholving some pkgs
in nixpkgs.

### Improved resolution
- Resolve command arguments to `type` builtin
- Nix API: Support intra-package inputs (#26)
    - Update to binlore v0.2.0
    - Split resholvePackage builds into 2 steps
        - an unresholved build of the package
        - a 2nd "resholved" building atop the first

### Improved interface
- Fix directive quoting issue documented in #76
    - Nix API: quote space-containing directives
    - Output quoted directives in file footer

### Internal
- First draft of documentation single-sourcing via wordswurst. There's still a lot left to do (I skimped on effort/principle in a large part of the Nixpkgs-README, for example).
- As part of the above, take the first teeny-tiny step towards breaking resholve up into more than one Python file. (I don't have much zeal for this--it's busywork when there's plenty of feature-work--but I think it makes sense to pilot here because I'm pushing these bits out to make them easier to generate.)

## v0.6.9 (Jan 20 2022)
- Fix sed parser bug (https://github.com/abathur/resholve/issues/71)
- Fix alias-substitution regression (https://github.com/abathur/resholve/issues/72)

## v0.6.8 (Nov 12 2021)
- Fix script parser bug (https://github.com/abathur/resholve/issues/70)

## v0.6.7 (Oct 4 2021)
- Fix sed parser bug
- Add dc handler/parser

## v0.6.6 (Sep 26 2021)
- resholvePackage now respects/merges additional buildInputs supplied by the caller
- fix "keep" directive for a variable _part_ of a firstword

## v0.6.5 (Sep 26 2021)
- Let awk handler time out (in case the awk script won't complete) without input conditions we can't understand)
- Apply the same handler to gawk

## v0.6.4 (Sep 25 2021)
- Fix & refine awk handler

## v0.6.3 (Sep 25 2021)
- support single-part keep directives for PWD-relative `./paths`

## v0.6.2 (Sep 25 2021)
- Fix https://github.com/abathur/resholve/issues/34

## v0.6.1 (Sep 23 2021)
- Extract Nix utility funcs from `resholvePackage` in order to add `resholveScript` and `resholveScriptBin`

## v0.6.0 (Sep 14 2021)

In order to support a few new features, I've refactored a fair fraction of resholve's command-visitor and resolution process. I'll focus on what I've added, but fair warning: slips/regressions are more likely with this update.

### Improved build-blocking/errors
- Require "lore" specifying whether every external executable it encounters can, cannot, or might (default) execute its own arguments.
    - Executables marked "cannot" are not checked for sub-executions.
    - Executables marked "might" or "can" must either have:
        - a command handler in resholve itself
        - a directive to tell resholve if there's anything else to resolve
    - I'm developing the default/~reference lore provider as a separate project: https://github.com/abathur/binlore. (It is responsible for evaluating each executable and printing judgements in the appropriate format.)
    - The lore format (see [Binlore: Lore Formats](https://github.com/abathur/binlore#lore-formats) for more) is simple to write or generate.
- Block Nix builds if a script uses some executables that, in Nix land, must use setuid wrappers. Details in https://github.com/abathur/resholve/issues/29, but generally this exists to catch users at risk of falling into some Nix traps.

### Improved resolution
- Separate per-command handlers (previously: shared handlers for ~similar builtins/commands) to better accommodate syntax/usage quirks of individual commands like variable assignments, flags, exec's fd behavior, varying sub-executable locations, etc.
    - builtins: builtin, command, coproc, eval, exec, source. (Note: `time` is technically a keyword. Thus far, the OSH parser's handling of time has sheltered resholve from needing to consider it.)
    - externals: coreutils (chroot env install nice nohup runcon sort split stdbuf timeout), sed, sudo (but not w/ Nix), findutils (find\*, xargs), rlwrap, sqlite3, a number of shells, (gnu|bsd)tar
    - Most of these have their own Argparse syntax parser. In the first draft this was bespoke. I may eventually go back in that direction, but it was too much change-overhead in the short-run.
- Recursively resolve command-executing commands (previously: a single level of sub-resolution).
- Resolve backslash-escaped commands (used to skip alias expansion), leaving the backslash in place.
- Unified handling of "dynamic" syntax handling (what kinds of substitutions and expansions resholve does and doesn't require exemptions for) across different contexts to make it more consistent. (These had ~speciated, so there's a higher risk of regressions and nonsense combinations here.)
- resholve now handles its own PATH lookups to support two improvements:
    - Lookup will also match against full file paths in the inputs. This makes it easier to obtain one of resholve's big benefits--finding and declaring all external dependencies--even if you're using executables from general system directories.
    - Lookup won't match files in PWD unless PWD or the individual files are explicitly added to the inputs.
- resholve can now substitute `$VARSUB` and `${VARSUB}` with a fix directive (i.e. `--fix '$VARSUB:replacement'). Replacements are made before resolution, so they will be subject to normal resolution rules during the primary pass. This makes it possible to fix variable-as-command cases, where you might do something like `--fix '$GIT_COMMAND:git'. (resholve should already force you to fix a variable used as a command.) This isn't dynamic; it replaces the whole varsub (even if it's an array access) with the provided value.


### Internal
- To simplify separating the handlers for each builtin/command, resholve now treats invocations of the `.` builtin as if they used `source`. It won't make this translation in the source, but it does mean that any
- Exit statuses have been *very* ad-hoc so far, and now they're only *fairly* ad-hoc.

    This is under "internal" for a reason: resholve's statuses are a testing affordance. They aren't systematic. I have not decided if I will re-use an old status for semantically-new errors. I have not decided what I'll do with a status if I speciate an error into two more-specific errors. Use them if they help you, but keep an eye out for changes.

    Specifics:

    - resholve now _aspires_ to avoid status 1 for resholve-specific errors. This is predicated on the _assumption_ that errors raised by the underlying osh parser will use status 1 (unless resholve intentionally catches, changes, and re-raises them).
    - resholve now _aspires_ to use status 2 for all invocation errors. (Some assertion-checked invocation errors previously resulted in status 1).
    - resholve now _aspires_ to use a distinct 3+ status for each distinct error class. I refactored resolution errors to give each error its own class and make it harder to row in the wrong direction.
    - Existing status numbers have been updated to eliminate gaps in the status numbers used.
        - unresolved source 7 -> 4
        - unresolvable dynamic command 9 -> 7
- resholve's test runs now report timings, and I'm storing a generated copy in [timings.md](timings.md). I've wanted this for a while, but I've been waiting for a bats release this March that changed from second -> ms precision. I hope this will create some vague record of performance over time, but I may scrap it if even single-machine timings are too noisy to make sense of.
- resholve has been directly interfacing with the Oil AST, but I've shimmed in our own abstraction, something like `Invocation([Word(AST), Word(AST), ...])`, to contain AST-related logic.


### Migrating
- Directives specifying `.` should be updated to use `source`.
- To resolve references to files in PWD, you'll have to explicitly add either the current directory or the individual files to --(path|inputs).
- If you have any scripts that depend on resholve's non-0 error statuses, double-check them. Some (but not all) error statuses have changed.

    
## v0.5.1 (Mar 4 2021)
Fix re-resolution of an existing abspath command (specified via --fix abspath), which was incorrectly replacing the basename with the new abspath instead of replacing the entire command path.

## v0.5.0 (Feb 26 2021)
Update resholve's oil dependency from ~0.8.pre4 to 0.8.7. In theory this should have little real impact since resholve's own options/APIs remain unchanged, but the impacts certainly *could* be greater than a normal bugfix release.

## v0.4.3 (Feb 21 2021)
Fix missing $V/${V} normalization in --keep command:$var forms (this prevented ${V} from being exempted correctly).

## v0.4.2 (Jan 24 2021)
Fix a bug that caused the shebang not to be correctly generated in some circumstances.

## v0.4.1 (Jan 11 2021)
The Nix API now uses a workaround to avoid leaking resholve's python dependencies into the environment of packages that use `resholve` or `resholvePackage`.

## v0.4.0 (Jan 4 2021)
I've updated the Nix API to address some PR feedback. This isn't really a functional change, but it does flatten out the namespace:
- `resholve.resholve` should now be `resholve`
- `resholve.resholvePackage` should now be `resholvePackage`

Before this change, I consumed resholve myself with something like:
```nix
resholve = self.callPackage ../pkgs/resholve { };
```

I now consume it like:

```nix
inherit (self.callPackage ../pkgs/resholve { })
  resholve resholvePackage;
```

## v0.3.0 (Dec 30 2020)
- require exemption to source abspaths (i.e. `--keep source:abspath`). This path will still have to exist--because resholve will need to parse the sourced file.
- related to above, added a `source:path` fake directive for instructing resholve not to parse or care about the existence of a sourced file (try not to use this)
- added a `--keep ~/path` form, which allows invocations of a specific user-home-relative path

## v0.2.1 (Dec 27 2020)
- support basic `coproc command` syntax

## v0.2.0 (Dec 27 2020)
- add `--inputs` and `RESHOLVE_INPUTS` as aliases of `--path`
  and `RESHOLVE_PATH`
- add a plaintext copy of the manpage as stopgap documentation
  and update README
- support multiple resholve invocations per package from Nix API

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
