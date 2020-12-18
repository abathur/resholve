# resholve references to external dependencies in shell scripts

![Test](https://github.com/abathur/resholve/workflows/Test/badge.svg)

resholve replaces references to a bash/shell script's external 
dependencies (commands and sourced scripts) with absolute paths, ensuring
they are declared, present, and don't shift if PATH changes.

Some people think of resholve as the missing linker for bash scripts.

It treats references it can't resolve as errors (to block a build, 
install, package, or deploy process) until you tell it how to handle 
them, and then rewrites the script according to your instructions.

Convinced? Jump to the [Quickstart](#quickstart). Otherwise, read on.

## Wait, what?

Fair! It took me a while to figure out resholve should exist, myself. 
If you aren't sure you need it, you *probably* don't. Still, you should
read a *bit* further so you'll recognize the needs resholve meets if you
encounter them someday :)

(If you change your mind from here on, please open an issue to help me 
understand how you're thinking about this and refine the intro.)

- If you want to understand what problems resholve addresses, read the next section.
- If you want to see invocations and output, the [Demos](demos.md) document is a good place to start.

## What problem(s) does this solve?

I've designed resholve as a generic utility, but I'm building it to improve support for shell libraries/modules in [Nix](https://nixos.org/nix/)/[Nixpkgs](https://github.com/NixOS/nixpkgs).

Here are a few things resholve is already helping us do in the Nix ecosystem:
- discover and declare dependencies at package time instead of after runtime failures
    - keep unexpected versions of an executable or script from causing undefined behavior
- avoid polluting PATH with all of a script's dependencies, which also means
    - no conflicts between things different scripts need on PATH
    - no conflicts with the packages a user expects on PATH
    - no implicit (and potentially fragile) dependency on the content
      and execution-order of a user's shell rc/profile
- work directly with "normal" shell scripts
    - no polluting *source* scripts with template variables/syntax
    - no inlining shell scripts to readily inject absolute paths
    - no fragile .patch files
    - no fragile sed/awk text substitutions that might over-match

(feel free to open a PR/issue to document uses you discover!)

## Quickstart
> *Note:* resholve is a young project. It *works for a living* already, but not much is done beyond the golden path. For example, resholve is *only* packaged for the [Nix package manager](https://nixos.org/nix/). You may want to review the [limitations](#limitations) section for more.

This section focuses on getting resholve to play with it. Once you have it, you should review `man resholve` (or the [plaintext](resholve.1.txt) copy).

### CLI
resholve isn't quite in nixpkgs yet, but once it is, you can try it
out by running

```shell
nix-shell -p resholve
# I recommend nix-shell for 'man resholve' support.
```

### Nix builder
TODO

### DIY

```shell
git clone https://github.com/abathur/resholve.git
cd resholve
nix-shell
# or nix-build, but I recommend nix-shell for 'man resholve' support
```

## Acknowledgements
- resholve leverages the [Oil](https://github.com/oilshell/oil) shell's OSH parser) and wouldn't be feasible without Andy Chu's excellent work on that project.

## Limitations
If you have short-term plans to *depend* on resholve, I recommend making sure you understand its limitations.

### Documentation
- The manpage is currently the canonical reference to resholve's options and behavior; the only online format is [plaintext](resholve.1.txt). See #19.
- The existing documentation doesn't really address the Nix API, though there are some examples.

### Packaging
- My short-term goal is to support packaging shell projects for the [Nix package manager](https://nixos.org/nix/) (and hopefully getting this support into Nixpkgs). As such, the current build process depends on Nix. 
    - The Nix API probably isn't granular enough, yet. It doesn't handle scripts in a single package that need different config/interpreters/etc.
- *If you're interested in using resholve without Nix, I'll appreciate contributions that fill in traditional Python build support.*
- For simplicity, resholve technically cheats by using nixpkgs python2 rather than Oil's fork of python2. I haven't noticed any issues that look like this, but there's always some nonzero chance that this is causing problems that I just haven't noticed.

### Known Gaps & Edge Cases in the utility itself

Because Shell is a very flexible, tricky language, resholve necessarily focuses on low-hanging-fruit tasks. Some of these will inevitably be supported over time, while others may stay out of reach. Please open an issue if you find a new one (and can't find an existing issue first).

The main areas I'm currently aware of:

- resholve makes no attempt to perform deep/recursive analysis on commands that run other commands. Plainly: resholve *does* try to verify that "blah" in `command blah` resolves to a real command--but it won't resolve it if you do something cute like `command command command blah`. 
- resholve doesn't have robust handling of variables that get executed like commands (this includes things like `eval $variable` and `"$run_as_command"` and `$GIT_COMMAND status`). There's some room for improvement here, but I also want to manage expectations because some cases are completely intractable without evaluating the script.
    - there's a first-level complication about seeing-through the variables themselves
    - and then a second-level issue with seeing-through double-quoted strings (for example, an eval )
- `fc -s` has interesting behavior that makes it hard to account for
    - if I run `ls /tmp` and then `echo blah` and then `fc -s 'ls'`, it'll re-run that previous ls command
        - if resholve rewrites ls to an absolute path, the fc -s command won't work as expected unless we also expand the ls inside the fc command
    - if I run `ls /tmp` and then `fc -s tmp=sbin`, it'll run `ls /sbin`; if I then run `fc -s ls=stat`, it runs `stat /sbin`
        - accounting for and triaging this will be very hard; there are no strict semantics here; we can substitute arbitrary text which could be executable names or arguments or even just parts of them; we'd have to be very explicitly parsing things out, or maybe extracting them into a mock test and running it, to know what to do
    - For now this is unaddressed. It probably makes the most sense to just raise a warning about not handling fc and link to a doc or issue about it, but I'm inclined to put this off until someone asks about it.
