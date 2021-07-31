# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..62
ok 1 verify warnings are thrown for quoted evals in 365ms
ok 2 verify --keep '' allows dynamic commands in 384ms
ok 3 verify --fix ':cmd' substitutes dynamic commands in 426ms
ok 4 can resolve a simple coproc in 348ms
ok 5 can't resolve a named coproc w/o upstream support :( in 658ms
ok 6 objects to unexempted absolute source paths in 324ms
ok 7 allows exempted absolute source paths in 355ms
ok 8 allow (but do not parse) --fake 'source:path' in 325ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 625ms
ok 10 objects to unexempted tilde executable paths in 329ms
ok 11 allows exempted tilde executable paths in 350ms
ok 12 allows --fake executable in 326ms
ok 13 allows --fake function with colons in 325ms
ok 14 resolve abspath with --fix abspath in 318ms
ok 15 resolve fails without lore in 338ms
ok 16 resolve fails without assay in 280ms
ok 17 resolve fails with bad assay in 534ms
ok 18 resolve fails with overshooting assay wordnum in 540ms
ok 19 resolve fails with assay wordnum 0 in 277ms
ok 20 resolve fails with undershooting assay wordnum in 570ms
ok 21 resolve succeeds with assay in 293ms
ok 22 resolve commands mixed with varlike assignments in 338ms
ok 23 verify warnings are thrown for overridden builtins in 301ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 310ms
ok 25 invoking resholve without --interpreter prints an error in 551ms
ok 26 invoking resholve without path/inputs prints an error in 589ms
ok 27 invoking resholve with missing interpreter prints an error in 563ms
ok 28 invoking resholve with a relative interpreter prints an error in 567ms
ok 29 invoking resholve with a non-executable interpreter prints an error in 592ms
ok 30 invoking resholve without script's deps prints an error in 535ms
ok 31 ensure shebangs are identical in 553ms
ok 32 resholve resolves simple external dependency from command-line args in 548ms
ok 33 resholve resolves simple external dependency from stdin in 286ms
ok 34 path/inputs can be supplied with the inputs alias in 544ms
ok 35 only one of path/inputs can be supplied in 551ms
ok 36 resholve fails if target script isn't found in 539ms
ok 37 resholve fails with duplicate input scripts in 286ms
ok 38 resholve fails when scripts have untriaged dynamic elements in 553ms
ok 39 resholve fails when 'keep' directives are misformatted in 878ms
ok 40 resholve fails when triage directive doesn't specify the right thing in 1959ms
ok 41 resholve succeeds when 1x 'keep' directives are correct in 818ms
ok 42 resholve succeeds when 2x 'keep' directives are correct in 1489ms
ok 43 don't resolve aliases without '--fix aliases' in 343ms
ok 44 inject before and after script in 582ms
ok 45 fail with bad lore argument in 305ms
ok 46 accept good lore argument in 291ms
ok 47 'which' needs to be in RESHOLVE_PATH in 291ms
ok 48 Even in a function, 'which' needs to be in RESHOLVE_PATH in 291ms
ok 49 Absolute executable paths need exemptions in 282ms
ok 50 Even nested-executable paths need exemptions in 303ms
ok 51 Source, among others, needs an exemption for arguments containing variables in 291ms
ok 52 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 309ms
ok 53 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 328ms
ok 54 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 301ms
ok 55 Add an exemption with --keep <scope>:<name> in 300ms
ok 56 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 315ms
ok 57 'source' targets also need to be in RESHOLVE_PATH in 291ms
ok 58 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 331ms
ok 59 Has (naive) context-specific resolution rules in 359ms
ok 60 Has (rudimentary) support for resolving executable arguments in 327ms
ok 61 Can substitute a variable used as a command in 335ms
ok 62 modern resholve versions reject v1 files in 319ms
```
