# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..63
ok 1 verify warnings are thrown for quoted evals in 380ms
ok 2 verify --keep '' allows dynamic commands in 389ms
ok 3 verify --fix ':cmd' substitutes dynamic commands in 378ms
ok 4 can resolve a simple coproc in 410ms
ok 5 can't resolve a named coproc w/o upstream support :( in 698ms
ok 6 objects to unexempted absolute source paths in 384ms
ok 7 allows exempted absolute source paths in 417ms
ok 8 allow (but do not parse) --fake 'source:path' in 385ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 720ms
ok 10 objects to unexempted tilde executable paths in 387ms
ok 11 allows exempted tilde executable paths in 394ms
ok 12 allows --fake executable in 397ms
ok 13 allows --fake function with colons in 374ms
ok 14 resolve abspath with --fix abspath in 399ms
ok 15 resolve fails without lore in 357ms
ok 16 resolve fails without assay in 311ms
ok 17 resolve fails with bad assay in 613ms
ok 18 resolve fails with overshooting assay wordnum in 611ms
ok 19 resolve fails with assay wordnum 0 in 318ms
ok 20 resolve fails with undershooting assay wordnum in 605ms
ok 21 resolve succeeds with assay in 316ms
ok 22 resolve commands mixed with varlike assignments in 329ms
ok 23 verify warnings are thrown for overridden builtins in 317ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 333ms
ok 25 invoking resholve without --interpreter prints an error in 598ms
ok 26 invoking resholve without path/inputs prints an error in 602ms
ok 27 invoking resholve with missing interpreter prints an error in 654ms
ok 28 invoking resholve with a relative interpreter prints an error in 640ms
ok 29 invoking resholve with a non-executable interpreter prints an error in 635ms
ok 30 invoking resholve without script's deps prints an error in 676ms
ok 31 ensure shebangs are identical in 623ms
ok 32 resholve resolves simple external dependency from command-line args in 634ms
ok 33 resholve resolves simple external dependency from stdin in 332ms
ok 34 path/inputs can be supplied with the inputs alias in 748ms
ok 35 only one of path/inputs can be supplied in 639ms
ok 36 resholve fails if target script isn't found in 654ms
ok 37 resholve fails with duplicate input scripts in 321ms
ok 38 resholve fails when scripts have untriaged dynamic elements in 621ms
ok 39 resholve fails when 'keep' directives are misformatted in 917ms
ok 40 resholve fails when triage directive doesn't specify the right thing in 3944ms
ok 41 resholve succeeds when 1x 'keep' directives are correct in 1189ms
ok 42 resholve succeeds when 2x 'keep' directives are correct in 1617ms
ok 43 resholve accepts empty directives in 472ms
ok 44 don't resolve aliases without '--fix aliases' in 452ms
ok 45 inject before and after script in 717ms
ok 46 fail with bad lore argument in 343ms
ok 47 accept good lore argument in 317ms
ok 48 'which' needs to be in RESHOLVE_PATH in 335ms
ok 49 Even in a function, 'which' needs to be in RESHOLVE_PATH in 346ms
ok 50 Absolute executable paths need exemptions in 333ms
ok 51 Even nested-executable paths need exemptions in 344ms
ok 52 Source, among others, needs an exemption for arguments containing variables in 354ms
ok 53 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 526ms
ok 54 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 366ms
ok 55 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 334ms
ok 56 Add an exemption with --keep <scope>:<name> in 350ms
ok 57 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 325ms
ok 58 'source' targets also need to be in RESHOLVE_PATH in 326ms
ok 59 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 353ms
ok 60 Has (naive) context-specific resolution rules in 370ms
ok 61 Has (rudimentary) support for resolving executable arguments in 444ms
ok 62 Can substitute a variable used as a command in 565ms
ok 63 modern resholve versions reject v1 files in 353ms
```
