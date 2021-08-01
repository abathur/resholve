# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..62
ok 1 verify warnings are thrown for quoted evals in 370ms
ok 2 verify --keep '' allows dynamic commands in 347ms
ok 3 verify --fix ':cmd' substitutes dynamic commands in 346ms
ok 4 can resolve a simple coproc in 316ms
ok 5 can't resolve a named coproc w/o upstream support :( in 1210ms
ok 6 objects to unexempted absolute source paths in 370ms
ok 7 allows exempted absolute source paths in 412ms
ok 8 allow (but do not parse) --fake 'source:path' in 384ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 674ms
ok 10 objects to unexempted tilde executable paths in 343ms
ok 11 allows exempted tilde executable paths in 351ms
ok 12 allows --fake executable in 365ms
ok 13 allows --fake function with colons in 328ms
ok 14 resolve abspath with --fix abspath in 326ms
ok 15 resolve fails without lore in 366ms
ok 16 resolve fails without assay in 289ms
ok 17 resolve fails with bad assay in 598ms
ok 18 resolve fails with overshooting assay wordnum in 562ms
ok 19 resolve fails with assay wordnum 0 in 300ms
ok 20 resolve fails with undershooting assay wordnum in 566ms
ok 21 resolve succeeds with assay in 289ms
ok 22 resolve commands mixed with varlike assignments in 305ms
ok 23 verify warnings are thrown for overridden builtins in 290ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 297ms
ok 25 invoking resholve without --interpreter prints an error in 539ms
ok 26 invoking resholve without path/inputs prints an error in 544ms
ok 27 invoking resholve with missing interpreter prints an error in 531ms
ok 28 invoking resholve with a relative interpreter prints an error in 536ms
ok 29 invoking resholve with a non-executable interpreter prints an error in 538ms
ok 30 invoking resholve without script's deps prints an error in 543ms
ok 31 ensure shebangs are identical in 554ms
ok 32 resholve resolves simple external dependency from command-line args in 573ms
ok 33 resholve resolves simple external dependency from stdin in 287ms
ok 34 path/inputs can be supplied with the inputs alias in 551ms
ok 35 only one of path/inputs can be supplied in 532ms
ok 36 resholve fails if target script isn't found in 534ms
ok 37 resholve fails with duplicate input scripts in 281ms
ok 38 resholve fails when scripts have untriaged dynamic elements in 547ms
ok 39 resholve fails when 'keep' directives are misformatted in 802ms
ok 40 resholve fails when triage directive doesn't specify the right thing in 1933ms
ok 41 resholve succeeds when 1x 'keep' directives are correct in 817ms
ok 42 resholve succeeds when 2x 'keep' directives are correct in 1433ms
ok 43 don't resolve aliases without '--fix aliases' in 328ms
ok 44 inject before and after script in 546ms
ok 45 fail with bad lore argument in 287ms
ok 46 accept good lore argument in 286ms
ok 47 'which' needs to be in RESHOLVE_PATH in 285ms
ok 48 Even in a function, 'which' needs to be in RESHOLVE_PATH in 295ms
ok 49 Absolute executable paths need exemptions in 285ms
ok 50 Even nested-executable paths need exemptions in 286ms
ok 51 Source, among others, needs an exemption for arguments containing variables in 295ms
ok 52 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 294ms
ok 53 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 290ms
ok 54 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 289ms
ok 55 Add an exemption with --keep <scope>:<name> in 284ms
ok 56 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 284ms
ok 57 'source' targets also need to be in RESHOLVE_PATH in 288ms
ok 58 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 315ms
ok 59 Has (naive) context-specific resolution rules in 351ms
ok 60 Has (rudimentary) support for resolving executable arguments in 313ms
ok 61 Can substitute a variable used as a command in 333ms
ok 62 modern resholve versions reject v1 files in 295ms
```
