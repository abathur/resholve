# status
resholve's documentation is in the early stages of cleanup and consolidation.

This is still effectively a solo project, so I'm hoping to single-source as much of the documentation as possible and feed it into both the code and docs to minimize chances for drift.

# This directory
Contains an experiment in single-sourcing powered by another tool I'm writing, [wordswurst](https://github.com/abathur/wordswurst). You can read source there, but basically:
- wordswurst combines a semantic ~authoring language called D★Mark with a (currently unnamed) variant of ~CSS adapted for controlling plain-text layout.
- content.wwst contains the primary corpus of text
- remaining *.wwst files select detail from content.wwst, contain glue text, and specify a ~CSS stylesheet that wordswurst will use to render the output
- *.scss files are the source for the CSS stylesheets (the rendered versions shouldn't be committed)

> Notes: 
> 1. Yes, I realize this is complex, bespoke, and may make some people leery of touching the docs.
> 2. No, I couldn't just use Jinja/Mustache + yaml for this. I tried and failed this (along with a few more obscure approaches). The whitespace control is not fine-grained enough to support outputting valid, idiomatic markdown, mdoc, and python source.

# outputs
Summary of what we've got and what I imagine we need.

## Current
Current forms of documentation are:
- CLI `--help` (just a short syntax summary)
- manpage (addresses only the CLI)
    - resholve.1
    - resholve.1.txt (rendered plaintext)
- This repo's README.md (TODO)
- The README.md in nixpkgs
    - focuses on the Nix API, but explains enough of the CLI concepts that I hope people can supplement w/ the manpage
    - includes some additional information on the lore format and thus on binlore
    - hopefully in sync with README.nixpkgs.md)
- binlore: limited documentation in README, leans heavily on self-serve from real-world use examples
- yallback: limited documentation in README, leans heavily on self-serve from real-world use examples

## Future
- A site? (probably with both CLI and Nix API docs; unclear if this would just be resholve, or if it'd address the big-picture/umbrella including binlore and yallback.
- Standalone documentation of the lore format.
- ~full documentation of binlore as an implementation of the format including how it uses YARA, yallback, and overrides.
- The current Nixpkgs README probably needs to graduate into one or more sections in the nixpkgs manual (probably a subsection of a "shell packaging" section?)
    - Needs the equivalent of the current Nix API docs
    - Full documentation of resholve's option types (either directly integrated, or a direct link to a digestible web version).
    - Enough
- Somewhere/somehow, contributing documentation on what people can do to pitch in (where I need the most help, what the smallest bites are and how to make them.)
