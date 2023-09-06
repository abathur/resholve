# resholve references to external dependencies in shell scripts

![Test](https://github.com/abathur/resholve/workflows/Test/badge.svg)

resholve ensures shell script dependencies are declared, present, and don't break or shift if PATH changes. It helps turn shell scripts and libraries into reliable, self-contained packages that you can use as building blocks.

resholve treats external references to commands and sourced scripts as built-blocking errors until you declare them. Once they're all declared, it rewrites the references to absolute paths.

Comparisons:
- a linker for bash scripts
- [patchelf](https://github.com/NixOS/patchelf) for shell scripts

Convinced? Jump to the [Quickstart](#quickstart). Otherwise:
- If you want to understand what problems resholve addresses, read the next section.
- If you want to see invocations and output, the [Demos](demos.md) document is a good place to start.

## What problem(s) does this solve?

resholve is a generic tool, but I built it so [Nix](https://nixos.org/nix/)/[Nixpkgs](https://github.com/NixOS/nixpkgs) can have have great shell packaging.

In the Nix ecosystem, resholve helps us:
- discover and declare dependencies at package time instead of after runtime failures
    - keep unexpected versions of an executable or script from causing undefined behavior
- avoid polluting PATH with all of a script's dependencies, which also means
    - no conflicts between tools different scripts need on PATH
    - no conflicts with other packages a user expects on PATH
    - no implicit dependency on the content of fragile rc/profile scripts
- work directly with "normal" shell scripts
    - no polluting *source* scripts with template variables/syntax
    - no inlining shell scripts to readily inject absolute paths
    - no fragile .patch files
    - no fragile sed/awk text substitutions that might over-match

## Quickstart

If you use Nix, you'll want to use resholve's Nix API/builders included in nixpkgs. Two good places to start:
- API reference: [NixOS/nixpkgs: pkgs/development/misc/resholve/README.md](https://github.com/nixos/nixpkgs/blob/master/pkgs/development/misc/resholve/README.md).

- [Examples via GitHub code search](https://github.com/search?q=language%3Anix+%2Fresholve%5C.%28mkDerivation%7CwriteScript%7CwriteScriptBin%7CphraseSolution%29%2F+-path%3A**%2Faliases.nix&type=code)

### CLI

If you'd like to look at scripting resholve or integrating it with other toolchains, you can also use the resholve CLI directly. resholve is only packaged with Nix for now, so you'll need it installed for both approaches:

```shell
# pull resholve from nixpkgs
NIXPKGS_ALLOW_INSECURE=1 nix-shell -p resholve

# DIY
git clone https://github.com/abathur/resholve.git
cd resholve
nix-shell

# In both cases, check `man resholve` for CLI usage
```

> **Note:** resholve uses python2 because the high-quality shell parser it's built on does. Setting the `NIXPKGS_ALLOW_INSECURE` env is necessary to try resholve out in a shell because `nixpkgs` has taken steps to root out run-time usage of python2. resholve *will* still work at build-time for use in Nix packages. To be safe, don't run resholve on untrusted input.
> 
> (This isn't permanent. resholve should eventually be able to move to python3.)

## Contributing
If you're looking to improve resholve or the broader ecosystem (resholve + binlore), feel free to open issue or reach out to me on Matrix or by email. 

There's much to do. Some of it is simple and straightforward. Some of it's creative and green-field. Some of it's difficult. I've focused on primary work at the expense of building an onramp for other contributors, but I'm happy to help you get started and use the opportunity to build the ramp as we go.

If you do make code changes, you should be able to validate the codebase locally by running `make ci`.

Some documentation updates entail updating generated files that currently require an adjacent checkout of nixpkgs--it's easiest to just bug me to do this for now.

> Caution: from a dev perspective, `shell.nix` and `default.nix` are a lie. The former is just for users to try the CLI, and the latter is in the form required by callPackage for syncing with nixpkgs.

## Acknowledgements
- resholve leverages the [Oil](https://github.com/oilshell/oil) shell's OSH parser) and wouldn't be feasible without Andy Chu's excellent work on that project.

<details><summary>

## Limitations

</summary>


### Documentation
- The manpage is currently the canonical reference to resholve's options and behavior; the only online format is [plaintext](resholve.1.txt). See https://github.com/abathur/resholve/issues/19.

### Packaging
- My short-term goal is to support packaging shell projects for the [Nix package manager](https://nixos.org/nix/). As such, the current build process depends on Nix. 

    *If you're interested in using resholve without Nix, I'll appreciate contributions that fill in build support for other environments.*

### Known Gaps & Edge Cases in the utility itself

Because Shell is a very flexible, tricky language, resholve necessarily focuses on low-hanging-fruit tasks. Some of these will inevitably be supported over time, while others may stay out of reach. Please open an issue if you find a new one (and can't find an existing issue first).

The main areas I'm currently aware of:

- In any Nix build, resholve now blocks resolution of some fundamental external utilities (such as su and sudo) that use run wrappers in NixOS. See https://github.com/abathur/resholve/issues/29 for more.
- Because resholve makes assumptions about the behavior of some builtins in order to resolve scripts, it blocks if it looks like one is overridden by a function or alias. (This can likely be relaxed once I have a better sense of who/what/when/where/why/how these are overridden).
- resholve doesn't have robust handling of variables that get executed like commands (this includes things like `eval $variable` and `"$run_as_command"` and `$GIT_COMMAND status`). There's some room for improvement here, but I also want to manage expectations because some cases are completely intractable without evaluating the script.
    - there's a first-level complication about seeing-through the variables themselves
    - and then a second-level issue with seeing-through double-quoted strings (for example, an eval )
- `fc -s` has interesting behavior that makes it hard to account for
    - if I run `ls /tmp` and then `echo blah` and then `fc -s 'ls'`, it'll re-run that previous ls command
        - if resholve rewrites ls to an absolute path, the fc -s command won't work as expected unless we also expand the ls inside the fc command
    - if I run `ls /tmp` and then `fc -s tmp=sbin`, it'll run `ls /sbin`; if I then run `fc -s ls=stat`, it runs `stat /sbin`
        - accounting for and triaging this will be very hard; there are no strict semantics here; we can substitute arbitrary text which could be executable names or arguments or even just parts of them; we'd have to be very explicitly parsing things out, or maybe extracting them into a mock test and running it, to know what to do
    - For now this is unaddressed. It probably makes the most sense to just raise a warning about not handling fc and link to a doc or issue about it, but I'm inclined to put this off until someone asks about it.

</details>
