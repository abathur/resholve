"""
This is a hopefully-temporary placeholder to help inch down
3 separate tracks:
- single-sourcing resholve's ~documentation
- automating parts of resholve's source and documentation to
  pull from the single-source above
- modularizing resholve's codebase

A few phases:
1. collect strings here and swap their use sites
2. replace this file with an output generated from strings.py.in
    - I already have all of the pieces for this, but I need to figure out how the active component involving j2cli works (the makefile is outside of a nix build, and I don't have j2cli installed systemwide; I either need to fold this in a nix build, or provide the command with nix-run, or use a shebang, or something...)
3. idk?
"""
description = "resholve replaces bare references (subject to a PATH search at runtime) to external commands and scripts with absolute paths. This is a terse reminder of flag names; see 'man resholve' for usage."
synopsis = "resholve options script ..."
scripts = "scripts to resolve ($out-relative paths)"
interpreter = "The absolute interpreter path for the script's shebang. The special value none ensures there is no shebang."
path = "A PATH-format list of directories and/or files to resolve external dependencies from."
# TODO: old version: alias for --path
inputs = "an alias for --path"
fake = "pretend some commands exist"
fix = "fix things we can't auto-fix/ignore"
keep = "keep things we can't auto-fix/ignore"
lore = "control nested resolution"
execer = "modify nested resolution"
wrapper = "modify nested resolution"
prologue = "insert file before resolved script"
epilogue = "insert file after resolved script"
overwrite = "Resolve script in-place (useful for out-of-tree builds)."
