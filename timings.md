# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..67
ok 1 verify warnings are thrown for quoted evals in 613ms
ok 2 verify --keep '$varname' allows dynamic commands in 618ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 580ms
ok 4 can resolve a simple coproc in 462ms
ok 5 can't resolve a named braced coproc w/o upstream support :( in 457ms
ok 6 can't resolve a named paren coproc w/o upstream support :( in 455ms
ok 7 objects to unexempted absolute source paths in 452ms
ok 8 allows exempted absolute source paths in 473ms
ok 9 allow (but do not parse) --fake 'source:path' in 464ms
ok 10 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 894ms
ok 11 objects to unexempted tilde executable paths in 458ms
ok 12 allows exempted tilde executable paths in 451ms
ok 13 allows --fake executable in 458ms
ok 14 allows --fake function with colons in 461ms
ok 15 resolve abspath with --fix abspath in 459ms
ok 16 resolve fails without lore in 480ms
ok 17 resolve fails without assay in 461ms
ok 18 resolve fails with bad assay in 879ms
ok 19 resolve fails with overshooting assay wordnum in 918ms
ok 20 resolve fails with assay wordnum 0 in 467ms
ok 21 resolve fails with undershooting assay wordnum in 883ms
ok 22 resolve succeeds with assay in 462ms
ok 23 resolve commands mixed with varlike assignments in 488ms
ok 24 verify warnings are thrown for overridden builtins in 469ms
ok 25 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 467ms
ok 26 don't get confused by input redirections in 472ms
ok 27 invoking resholve without --interpreter prints an error in 916ms
ok 28 invoking resholve without path/inputs prints an error in 891ms
ok 29 invoking resholve with missing interpreter prints an error in 873ms
ok 30 invoking resholve with a relative interpreter prints an error in 902ms
ok 31 invoking resholve with a non-executable interpreter prints an error in 885ms
ok 32 invoking resholve without script's deps prints an error in 922ms
ok 33 ensure shebangs are identical in 876ms
ok 34 resholve resolves simple external dependency from command-line args in 936ms
ok 35 resholve resolves simple external dependency from stdin in 482ms
ok 36 path/inputs can be supplied with the inputs alias in 922ms
ok 37 only one of path/inputs can be supplied in 970ms
ok 38 resholve fails if target script isn't found in 916ms
ok 39 resholve fails with duplicate input scripts in 473ms
ok 40 resholve fails when scripts have untriaged dynamic elements in 910ms
ok 41 resholve fails when 'keep' directives are misformatted in 1327ms
ok 42 resholve fails when triage directive doesn't specify the right thing in 3151ms
ok 43 resholve succeeds when 1x 'keep' directives are correct in 1378ms
ok 44 resholve succeeds when 2x 'keep' directives are correct in 2313ms
ok 45 resholve accepts empty directives in 495ms
ok 46 don't resolve aliases without '--fix aliases' in 558ms
ok 47 inject before and after script in 929ms
ok 48 inject before/after in multiple scripts in 503ms
ok 49 fail with bad lore argument in 495ms
ok 50 accept good lore argument in 474ms
ok 51 'which' needs to be in RESHOLVE_PATH in 479ms
ok 52 Even in a function, 'which' needs to be in RESHOLVE_PATH in 488ms
ok 53 Absolute executable paths need exemptions in 528ms
ok 54 Even nested-executable paths need exemptions in 497ms
ok 55 Source, among others, needs an exemption for arguments containing variables in 483ms
ok 56 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 472ms
ok 57 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 501ms
ok 58 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 478ms
ok 59 Add an exemption with --keep <scope>:<name> in 487ms
ok 60 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 476ms
ok 61 'source' targets also need to be in RESHOLVE_PATH in 485ms
ok 62 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 519ms
ok 63 Has (naive) context-specific resolution rules in 593ms
ok 64 Has (rudimentary) support for resolving executable arguments in 644ms
ok 65 Can substitute a variable used as a command in 578ms
ok 66 modern resholve versions reject v1 files in 501ms
ok 67 exercise built-in syntax parsers in 1464ms
```
