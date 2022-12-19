# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..66
ok 1 verify warnings are thrown for quoted evals in 613ms
ok 2 verify --keep '$varname' allows dynamic commands in 671ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 660ms
ok 4 can resolve a simple coproc in 557ms
ok 5 can't resolve a named coproc w/o upstream support :( in 1191ms
ok 6 objects to unexempted absolute source paths in 629ms
ok 7 allows exempted absolute source paths in 855ms
ok 8 allow (but do not parse) --fake 'source:path' in 626ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 846ms
ok 10 objects to unexempted tilde executable paths in 454ms
ok 11 allows exempted tilde executable paths in 430ms
ok 12 allows --fake executable in 873ms
ok 13 allows --fake function with colons in 606ms
ok 14 resolve abspath with --fix abspath in 412ms
ok 15 resolve fails without lore in 416ms
ok 16 resolve fails without assay in 413ms
ok 17 resolve fails with bad assay in 919ms
ok 18 resolve fails with overshooting assay wordnum in 834ms
ok 19 resolve fails with assay wordnum 0 in 484ms
ok 20 resolve fails with undershooting assay wordnum in 859ms
ok 21 resolve succeeds with assay in 423ms
ok 22 resolve commands mixed with varlike assignments in 468ms
ok 23 verify warnings are thrown for overridden builtins in 520ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 455ms
ok 25 don't get confused by input redirections in 438ms
ok 26 invoking resholve without --interpreter prints an error in 799ms
ok 27 invoking resholve without path/inputs prints an error in 779ms
ok 28 invoking resholve with missing interpreter prints an error in 791ms
ok 29 invoking resholve with a relative interpreter prints an error in 801ms
ok 30 invoking resholve with a non-executable interpreter prints an error in 821ms
ok 31 invoking resholve without script's deps prints an error in 788ms
ok 32 ensure shebangs are identical in 786ms
ok 33 resholve resolves simple external dependency from command-line args in 797ms
ok 34 resholve resolves simple external dependency from stdin in 542ms
ok 35 path/inputs can be supplied with the inputs alias in 955ms
ok 36 only one of path/inputs can be supplied in 821ms
ok 37 resholve fails if target script isn't found in 856ms
ok 38 resholve fails with duplicate input scripts in 414ms
ok 39 resholve fails when scripts have untriaged dynamic elements in 744ms
ok 40 resholve fails when 'keep' directives are misformatted in 1098ms
ok 41 resholve fails when triage directive doesn't specify the right thing in 2552ms
ok 42 resholve succeeds when 1x 'keep' directives are correct in 1138ms
ok 43 resholve succeeds when 2x 'keep' directives are correct in 1895ms
ok 44 resholve accepts empty directives in 394ms
ok 45 don't resolve aliases without '--fix aliases' in 471ms
ok 46 inject before and after script in 749ms
ok 47 inject before/after in multiple scripts in 414ms
ok 48 fail with bad lore argument in 371ms
ok 49 accept good lore argument in 361ms
ok 50 'which' needs to be in RESHOLVE_PATH in 376ms
ok 51 Even in a function, 'which' needs to be in RESHOLVE_PATH in 412ms
ok 52 Absolute executable paths need exemptions in 368ms
ok 53 Even nested-executable paths need exemptions in 363ms
ok 54 Source, among others, needs an exemption for arguments containing variables in 376ms
ok 55 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 368ms
ok 56 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 380ms
ok 57 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 399ms
ok 58 Add an exemption with --keep <scope>:<name> in 353ms
ok 59 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 374ms
ok 60 'source' targets also need to be in RESHOLVE_PATH in 365ms
ok 61 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 441ms
ok 62 Has (naive) context-specific resolution rules in 507ms
ok 63 Has (rudimentary) support for resolving executable arguments in 504ms
ok 64 Can substitute a variable used as a command in 473ms
ok 65 modern resholve versions reject v1 files in 413ms
ok 66 exercise built-in syntax parsers in 1279ms
```
