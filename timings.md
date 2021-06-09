# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
1..60
ok 1 verify warnings are thrown for quoted evals in 362ms
ok 2 verify --keep '' allows dynamic commands in 374ms
ok 3 can resolve a simple coproc in 333ms
ok 4 can't resolve a named coproc w/o upstream support :( in 609ms
ok 5 objects to unexempted absolute source paths in 297ms
ok 6 allows exempted absolute source paths in 369ms
ok 7 allow (but do not parse) --fake 'source:path' in 388ms
ok 8 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 603ms
ok 9 objects to unexempted tilde executable paths in 307ms
ok 10 allows exempted tilde executable paths in 307ms
ok 11 allows --fake executable in 288ms
ok 12 allows --fake function with colons in 286ms
ok 13 resolve abspath with --fix abspath in 274ms
ok 14 resolve fails without lore in 299ms
ok 15 resolve fails without assay in 276ms
ok 16 resolve fails with bad assay in 563ms
ok 17 resolve fails with overshooting assay wordnum in 563ms
ok 18 resolve fails with assay wordnum 0 in 288ms
ok 19 resolve fails with undershooting assay wordnum in 542ms
ok 20 resolve succeeds with assay in 313ms
ok 21 resolve commands mixed with varlike assignments in 317ms
ok 22 verify warnings are thrown for overridden builtins in 312ms
ok 23 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 320ms
ok 24 invoking resholve without --interpreter prints an error in 542ms
ok 25 invoking resholve without path/inputs prints an error in 547ms
ok 26 invoking resholve with missing interpreter prints an error in 535ms
ok 27 invoking resholve with a relative interpreter prints an error in 524ms
ok 28 invoking resholve with a non-executable interpreter prints an error in 554ms
ok 29 invoking resholve without script's deps prints an error in 535ms
ok 30 ensure shebangs are identical in 543ms
ok 31 resholve resolves simple external dependency from command-line args in 578ms
ok 32 resholve resolves simple external dependency from stdin in 286ms
ok 33 path/inputs can be supplied with the inputs alias in 557ms
ok 34 only one of path/inputs can be supplied in 556ms
ok 35 resholve fails if target script isn't found in 561ms
ok 36 resholve fails with duplicate input scripts in 273ms
ok 37 resholve fails when scripts have untriaged dynamic elements in 530ms
ok 38 resholve fails when 'keep' directives are misformatted in 805ms
ok 39 resholve fails when triage directive doesn't specify the right thing in 1788ms
ok 40 resholve succeeds when 1x 'keep' directives are correct in 808ms
ok 41 resholve succeeds when 2x 'keep' directives are correct in 1355ms
ok 42 don't resolve aliases without '--fix aliases' in 329ms
ok 43 inject before and after script in 532ms
ok 44 fail with bad lore argument in 276ms
ok 45 accept good lore argument in 269ms
ok 46 'which' needs to be in RESHOLVE_PATH in 274ms
ok 47 Even in a function, 'which' needs to be in RESHOLVE_PATH in 295ms
ok 48 Absolute executable paths need exemptions in 272ms
ok 49 Even nested-executable paths need exemptions in 274ms
ok 50 Source, among others, needs an exemption for arguments containing variables in 274ms
ok 51 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 275ms
ok 52 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 275ms
ok 53 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 283ms
ok 54 Add an exemption with --keep <scope>:<name> in 282ms
ok 55 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 278ms
ok 56 'source' targets also need to be in RESHOLVE_PATH in 275ms
ok 57 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 311ms
ok 58 Has (naive) context-specific resolution rules in 326ms
ok 59 Has (rudimentary) support for resolving executable arguments in 319ms
ok 60 modern resholve versions reject v1 files in 283ms
```
