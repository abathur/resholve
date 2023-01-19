# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..66
ok 1 verify warnings are thrown for quoted evals in 578ms
ok 2 verify --keep '$varname' allows dynamic commands in 528ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 588ms
ok 4 can resolve a simple coproc in 503ms
ok 5 can't resolve a named coproc w/o upstream support :( in 933ms
ok 6 objects to unexempted absolute source paths in 426ms
ok 7 allows exempted absolute source paths in 445ms
ok 8 allow (but do not parse) --fake 'source:path' in 425ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 796ms
ok 10 objects to unexempted tilde executable paths in 461ms
ok 11 allows exempted tilde executable paths in 415ms
ok 12 allows --fake executable in 416ms
ok 13 allows --fake function with colons in 426ms
ok 14 resolve abspath with --fix abspath in 424ms
ok 15 resolve fails without lore in 444ms
ok 16 resolve fails without assay in 417ms
ok 17 resolve fails with bad assay in 833ms
ok 18 resolve fails with overshooting assay wordnum in 833ms
ok 19 resolve fails with assay wordnum 0 in 431ms
ok 20 resolve fails with undershooting assay wordnum in 810ms
ok 21 resolve succeeds with assay in 426ms
ok 22 resolve commands mixed with varlike assignments in 428ms
ok 23 verify warnings are thrown for overridden builtins in 415ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 414ms
ok 25 don't get confused by input redirections in 406ms
ok 26 invoking resholve without --interpreter prints an error in 759ms
ok 27 invoking resholve without path/inputs prints an error in 749ms
ok 28 invoking resholve with missing interpreter prints an error in 750ms
ok 29 invoking resholve with a relative interpreter prints an error in 756ms
ok 30 invoking resholve with a non-executable interpreter prints an error in 752ms
ok 31 invoking resholve without script's deps prints an error in 762ms
ok 32 ensure shebangs are identical in 784ms
ok 33 resholve resolves simple external dependency from command-line args in 810ms
ok 34 resholve resolves simple external dependency from stdin in 409ms
ok 35 path/inputs can be supplied with the inputs alias in 777ms
ok 36 only one of path/inputs can be supplied in 762ms
ok 37 resholve fails if target script isn't found in 756ms
ok 38 resholve fails with duplicate input scripts in 407ms
ok 39 resholve fails when scripts have untriaged dynamic elements in 780ms
ok 40 resholve fails when 'keep' directives are misformatted in 1142ms
ok 41 resholve fails when triage directive doesn't specify the right thing in 2591ms
ok 42 resholve succeeds when 1x 'keep' directives are correct in 1175ms
ok 43 resholve succeeds when 2x 'keep' directives are correct in 1976ms
ok 44 resholve accepts empty directives in 419ms
ok 45 don't resolve aliases without '--fix aliases' in 469ms
ok 46 inject before and after script in 809ms
ok 47 inject before/after in multiple scripts in 434ms
ok 48 fail with bad lore argument in 410ms
ok 49 accept good lore argument in 387ms
ok 50 'which' needs to be in RESHOLVE_PATH in 399ms
ok 51 Even in a function, 'which' needs to be in RESHOLVE_PATH in 404ms
ok 52 Absolute executable paths need exemptions in 401ms
ok 53 Even nested-executable paths need exemptions in 404ms
ok 54 Source, among others, needs an exemption for arguments containing variables in 401ms
ok 55 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 400ms
ok 56 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 405ms
ok 57 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 412ms
ok 58 Add an exemption with --keep <scope>:<name> in 406ms
ok 59 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 400ms
ok 60 'source' targets also need to be in RESHOLVE_PATH in 402ms
ok 61 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 448ms
ok 62 Has (naive) context-specific resolution rules in 492ms
ok 63 Has (rudimentary) support for resolving executable arguments in 534ms
ok 64 Can substitute a variable used as a command in 482ms
ok 65 modern resholve versions reject v1 files in 410ms
ok 66 exercise built-in syntax parsers in 1083ms
```
