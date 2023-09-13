# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..67
ok 1 verify warnings are thrown for quoted evals in 404ms
ok 2 verify --keep '$varname' allows dynamic commands in 395ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 433ms
ok 4 can resolve a simple coproc in 336ms
ok 5 can't resolve a named braced coproc w/o upstream support :( in 348ms
ok 6 can't resolve a named paren coproc w/o upstream support :( in 325ms
ok 7 objects to unexempted absolute source paths in 375ms
ok 8 allows exempted absolute source paths in 368ms
ok 9 allow (but do not parse) --fake 'source:path' in 331ms
ok 10 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 651ms
ok 11 objects to unexempted tilde executable paths in 331ms
ok 12 allows exempted tilde executable paths in 332ms
ok 13 allows --fake executable in 327ms
ok 14 allows --fake function with colons in 389ms
ok 15 resolve abspath with --fix abspath in 351ms
ok 16 resolve fails without lore in 383ms
ok 17 resolve fails without assay in 357ms
ok 18 resolve fails with bad assay in 647ms
ok 19 resolve fails with overshooting assay wordnum in 664ms
ok 20 resolve fails with assay wordnum 0 in 341ms
ok 21 resolve fails with undershooting assay wordnum in 659ms
ok 22 resolve succeeds with assay in 359ms
ok 23 resolve commands mixed with varlike assignments in 436ms
ok 24 verify warnings are thrown for overridden builtins in 421ms
ok 25 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 357ms
ok 26 don't get confused by input redirections in 370ms
ok 27 invoking resholve without --interpreter prints an error in 1045ms
ok 28 invoking resholve without path/inputs prints an error in 751ms
ok 29 invoking resholve with missing interpreter prints an error in 975ms
ok 30 invoking resholve with a relative interpreter prints an error in 787ms
ok 31 invoking resholve with a non-executable interpreter prints an error in 727ms
ok 32 invoking resholve without script's deps prints an error in 673ms
ok 33 ensure shebangs are identical in 682ms
ok 34 resholve resolves simple external dependency from command-line args in 679ms
ok 35 resholve resolves simple external dependency from stdin in 360ms
ok 36 path/inputs can be supplied with the inputs alias in 667ms
ok 37 only one of path/inputs can be supplied in 668ms
ok 38 resholve fails if target script isn't found in 678ms
ok 39 resholve fails with duplicate input scripts in 356ms
ok 40 resholve fails when scripts have untriaged dynamic elements in 681ms
ok 41 resholve fails when 'keep' directives are misformatted in 1004ms
ok 42 resholve fails when triage directive doesn't specify the right thing in 2412ms
ok 43 resholve succeeds when 1x 'keep' directives are correct in 1021ms
ok 44 resholve succeeds when 2x 'keep' directives are correct in 1716ms
ok 45 resholve accepts empty directives in 369ms
ok 46 don't resolve aliases without '--fix aliases' in 444ms
ok 47 inject before and after script in 679ms
ok 48 inject before/after in multiple scripts in 374ms
ok 49 fail with bad lore argument in 357ms
ok 50 accept good lore argument in 350ms
ok 51 'which' needs to be in RESHOLVE_PATH in 339ms
ok 52 Even in a function, 'which' needs to be in RESHOLVE_PATH in 354ms
ok 53 Absolute executable paths need exemptions in 346ms
ok 54 Even nested-executable paths need exemptions in 347ms
ok 55 Source, among others, needs an exemption for arguments containing variables in 342ms
ok 56 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 351ms
ok 57 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 355ms
ok 58 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 353ms
ok 59 Add an exemption with --keep <scope>:<name> in 340ms
ok 60 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 345ms
ok 61 'source' targets also need to be in RESHOLVE_PATH in 340ms
ok 62 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 397ms
ok 63 Has (naive) context-specific resolution rules in 440ms
ok 64 Has (rudimentary) support for resolving executable arguments in 530ms
ok 65 Can substitute a variable used as a command in 455ms
ok 66 modern resholve versions reject v1 files in 362ms
ok 67 exercise built-in syntax parsers in 805ms
```
