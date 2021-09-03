# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..63
ok 1 verify warnings are thrown for quoted evals in 381ms
ok 2 verify --keep '$varname' allows dynamic commands in 391ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 382ms
ok 4 can resolve a simple coproc in 322ms
ok 5 can't resolve a named coproc w/o upstream support :( in 681ms
ok 6 objects to unexempted absolute source paths in 356ms
ok 7 allows exempted absolute source paths in 385ms
ok 8 allow (but do not parse) --fake 'source:path' in 344ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 671ms
ok 10 objects to unexempted tilde executable paths in 359ms
ok 11 allows exempted tilde executable paths in 365ms
ok 12 allows --fake executable in 355ms
ok 13 allows --fake function with colons in 347ms
ok 14 resolve abspath with --fix abspath in 386ms
ok 15 resolve fails without lore in 326ms
ok 16 resolve fails without assay in 311ms
ok 17 resolve fails with bad assay in 568ms
ok 18 resolve fails with overshooting assay wordnum in 572ms
ok 19 resolve fails with assay wordnum 0 in 295ms
ok 20 resolve fails with undershooting assay wordnum in 574ms
ok 21 resolve succeeds with assay in 301ms
ok 22 resolve commands mixed with varlike assignments in 321ms
ok 23 verify warnings are thrown for overridden builtins in 299ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 299ms
ok 25 invoking resholve without --interpreter prints an error in 565ms
ok 26 invoking resholve without path/inputs prints an error in 570ms
ok 27 invoking resholve with missing interpreter prints an error in 559ms
ok 28 invoking resholve with a relative interpreter prints an error in 566ms
ok 29 invoking resholve with a non-executable interpreter prints an error in 559ms
ok 30 invoking resholve without script's deps prints an error in 569ms
ok 31 ensure shebangs are identical in 570ms
ok 32 resholve resolves simple external dependency from command-line args in 595ms
ok 33 resholve resolves simple external dependency from stdin in 304ms
ok 34 path/inputs can be supplied with the inputs alias in 575ms
ok 35 only one of path/inputs can be supplied in 576ms
ok 36 resholve fails if target script isn't found in 589ms
ok 37 resholve fails with duplicate input scripts in 308ms
ok 38 resholve fails when scripts have untriaged dynamic elements in 589ms
ok 39 resholve fails when 'keep' directives are misformatted in 847ms
ok 40 resholve fails when triage directive doesn't specify the right thing in 1966ms
ok 41 resholve succeeds when 1x 'keep' directives are correct in 878ms
ok 42 resholve succeeds when 2x 'keep' directives are correct in 1439ms
ok 43 resholve accepts empty directives in 306ms
ok 44 don't resolve aliases without '--fix aliases' in 344ms
ok 45 inject before and after script in 594ms
ok 46 fail with bad lore argument in 322ms
ok 47 accept good lore argument in 305ms
ok 48 'which' needs to be in RESHOLVE_PATH in 296ms
ok 49 Even in a function, 'which' needs to be in RESHOLVE_PATH in 309ms
ok 50 Absolute executable paths need exemptions in 293ms
ok 51 Even nested-executable paths need exemptions in 302ms
ok 52 Source, among others, needs an exemption for arguments containing variables in 322ms
ok 53 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 310ms
ok 54 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 315ms
ok 55 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 300ms
ok 56 Add an exemption with --keep <scope>:<name> in 306ms
ok 57 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 297ms
ok 58 'source' targets also need to be in RESHOLVE_PATH in 298ms
ok 59 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 324ms
ok 60 Has (naive) context-specific resolution rules in 363ms
ok 61 Has (rudimentary) support for resolving executable arguments in 387ms
ok 62 Can substitute a variable used as a command in 346ms
ok 63 modern resholve versions reject v1 files in 313ms
```
