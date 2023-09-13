# resholve references to external dependencies in shell scripts

![Test](https://github.com/abathur/resholve/workflows/Test/badge.svg)

resholve ensures shell script dependencies are declared, present, and don't break or shift if PATH changes. It helps turn shell scripts and libraries into reliable, self-contained packages you can use as building blocks.

resholve treats references to external commands (and sourced scripts) as build-blocking errors until you declare the dependency. Once they're all declared, it rewrites the references to absolute paths.

Comparisons:
- a linker for bash scripts
- [patchelf](https://github.com/NixOS/patchelf) for shell scripts

Convinced? Jump to the [Quickstart](#quickstart). Otherwise:
- If you want to understand what problems resholve addresses, read the next section.
- If you want to see invocations and output, the [Demos](demos.md) document is a good place to start.

## What problem(s) does this solve?

I built resholve so [Nix](https://nixos.org/nix/)/[Nixpkgs](https://github.com/NixOS/nixpkgs) can have great shell packaging.

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

> **Note**: resholve is a generic command-line program. Other ecosystems/toolchains could use it for similar benefits.

## Quickstart

If you're packaging Shell with Nix, you'll want to use resholve's [Nix API](#nix-api).

You can also use resholve's [CLI](#cli) directly.

> **Note**: resholve is only packaged with Nix for now. Whether you use the CLI or the Nix API, you'll need to have Nix installed.

### Nix API

Since resholve's Nix API/builders are included in nixpkgs, most Nix users can jump right in. Two good places to start:
- API reference: [NixOS/nixpkgs: pkgs/development/misc/resholve/README.md](https://github.com/nixos/nixpkgs/blob/master/pkgs/development/misc/resholve/README.md).

- [Examples via GitHub code search](https://github.com/search?q=language%3Anix+%2Fresholve%5C.%28mkDerivation%7CwriteScript%7CwriteScriptBin%7CphraseSolution%29%2F+-path%3A**%2Faliases.nix&type=code)

> **Tip**: If you're an experienced packager or write a lot of Shell, you may also want to read through [resholve's Nix demo](demos.md#Nix-demo). It's terse, but it ~proves that Nix + resholve enable us to build shell packages that are so well-contained we can safely compose them even when they have conflicting dependencies.

### CLI

resholve has an explicit-is-better-than-implicit philosophy, so its CLI is pretty verbose. You _can_ use it directly, but it's more or less assumed that you'll use it through scripts or packaging toolchains. (You may not need to learn the CLI unless you're using it on scripts you can't build Nix expressions for, integrating it with other toolchains, packaging it, or contributing to resholve itself.)

If you're new to resholve, start with the [demo shell](#Demo-shell). 

If you just want resholve itself (no preconfigured demo environment), use the instructions for building/installing a [development version](#Development-versions) or a [stable version](#Stable-versions).

> **Note**: However you obtain the resholve CLI, check `man resholve` for CLI usage.

#### Demo shell

The demo shell pulls in prerequisites for resholve's command-line demo. This demo illustrates resholve's basic features, invocation patterns, output, error messages, exit statuses, and how resholving a script changes it.

The easy way to run the demo is with Nix's experimental `nix-command` and `flakes` features enabled. The following command will load the demo shell environment and print more information on how to proceed:

```shell
nix develop github:abathur/resholve
```

> **Note**: There's more on the demo's output format and a plaintext copy of the output in the [Demos](demos.md) document.

<details>
<summary>Traditional `nix-shell` instructions</summary>

You can also use the demo via `nix-shell` if you clone the repository:

```shell
git clone https://github.com/abathur/resholve.git
cd resholve
nix-shell
```

</details>

#### Development versions

resholve's `master` branch is fairly stable. If you have Nix's experimental nix-command and flakes features enabled, you should be able to use it with any of the below:

```shell
# without cloning
nix build github:abathur/resholve
nix shell github:abathur/resholve

# from the root of a resholve checkout
nix build
nix shell
```

<details>
<summary>Traditional `nix-build` instructions</summary>

You can build resholve from a checkout with the traditional CLI:

```shell
git clone https://github.com/abathur/resholve.git
cd resholve
nix-build
```

> **Caution**: The same isn't quite true of `nix-shell`, which will load the _demo_ shell. This might be fine for your purposes, but keep in mind that it pre-populates some environment variables just for the demo.

</details>

#### Stable versions

You can get a cached stable version of resholve from Nixpkgs:

```shell
# new CLI/flakes
NIXPKGS_ALLOW_INSECURE=1 nix shell --impure nixpkgs#resholve
NIXPKGS_ALLOW_INSECURE=1 nix shell --impure github:nixos/nixpkgs#resholve

# traditional CLI
NIXPKGS_ALLOW_INSECURE=1 nix-shell -p resholve
```

> **Note:** the high-quality shell parser resholve builds on uses python2. `nixpkgs` has taken steps to protect users from accidental _run-time_ use of python2. resholve *will* still work at build-time for use in Nix packages. You only need the `NIXPKGS_ALLOW_INSECURE` env to use nixpkgs' copy of resholve in a shell. To be safe, don't run resholve on untrusted input.
> 
> (This isn't permanent. resholve should eventually be able to move to python3.)

## Contributing
If you're looking to improve resholve or the broader ecosystem (resholve + [binlore](https://github.com/abathur/binlore)), feel free to open an issue, reach out to me on Matrix, or send an email.

There's much to do. Some of it is simple and straightforward. Some of it's creative and green-field. Some of it's difficult. I've focused on primary work at the expense of documenting an onramp for other contributors--but I'm happy to help you get started and use the opportunity to build the ramp as we go.

You can rebuild resholve by following [the instructions for building a development version](#development-versions). resholve's tests don't run during the build, so you should also validate the codebase by running `make ci`.

> **Note**: Some documentation updates entail updating generated files. I use `make update` for this, but this will also usually cause some churn in `timings.md` and `demos.md`. It's generally fine to skip committing those changes if they aren't meaningful. Feel free to bug me if you aren't comfortable doing this or need feedback.

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

Because Shell is a very flexible, tricky language, resholve necessarily focuses on low-hanging-fruit tasks. Some of these will inevitably be supported over time, while others may stay out of reach. Please open an issue if you find a new one.

The main areas I'm currently aware of:

- In any Nix build, resholve now blocks resolution of some fundamental external utilities (such as su and sudo) that use run wrappers in NixOS. See https://github.com/abathur/resholve/issues/29 for more.
- Because resholve makes assumptions about the behavior of some builtins in order to resolve scripts, it blocks if it looks like one is overridden by a function or alias. (This can likely be relaxed once I have a better sense of who/what/when/where/why/how these are overridden).
- resholve doesn't have robust handling of variables that get executed like commands (this includes things like `eval $variable` and `"$run_as_command"` and `$GIT_COMMAND status`). There's some room for improvement here, but I also want to manage expectations because some cases are completely intractable without evaluating the script.
    - there's a first-level complication about seeing-through the variables themselves
    - and then a second-level issue with seeing-through double-quoted strings (for example, an eval )
- `fc -s` has interesting behavior that makes it hard to account for:
    - If I run `ls /tmp` and then `echo blah` and then `fc -s 'ls'`, it'll re-run that previous ls command.
        - If resholve rewrites ls to an absolute path, the fc -s command won't work as expected unless we also expand the ls inside the fc command.
    - If I run `ls /tmp` and then `fc -s tmp=sbin`, it'll run `ls /sbin`; if I then run `fc -s ls=stat`, it runs `stat /sbin`.
        - Accounting for this will be hard. There are no strict semantics--it can substitute arbitrary text which could be executable names or arguments or even just parts of them. We'd have to be very explicitly parsing things out, or maybe extracting them into a mock test and running it, to know what to do.

    For now this is unaddressed. It probably makes the most sense to just raise a warning about not handling fc and link to a doc or issue about it, but I'm inclined to put this off until someone asks about it.

</details>
