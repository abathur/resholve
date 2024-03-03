# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..68
ok 1 verify warnings are thrown for quoted evals in 491ms
ok 2 verify --keep '$varname' allows dynamic commands in 519ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 492ms
ok 4 can resolve a simple coproc in 387ms
ok 5 can't resolve a named braced coproc w/o upstream support :( in 391ms
ok 6 can't resolve a named paren coproc w/o upstream support :( in 379ms
ok 7 objects to unexempted absolute source paths in 379ms
ok 8 allows exempted absolute source paths in 418ms
ok 9 allow (but do not parse) --fake 'source:path' in 374ms
ok 10 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 728ms
ok 11 objects to unexempted tilde executable paths in 376ms
ok 12 allows exempted tilde executable paths in 406ms
ok 13 allows --fake executable in 396ms
ok 14 allows --fake function with colons in 389ms
ok 15 resolve abspath with --fix abspath in 404ms
ok 16 resolve fails without lore in 421ms
ok 17 resolve fails without assay in 386ms
ok 18 resolve fails with bad assay in 756ms
ok 19 resolve fails with overshooting assay wordnum in 825ms
ok 20 resolve fails with assay wordnum 0 in 439ms
ok 21 resolve fails with undershooting assay wordnum in 787ms
ok 22 resolve succeeds with assay in 406ms
ok 23 resolve commands mixed with varlike assignments in 460ms
ok 24 verify warnings are thrown for overridden builtins in 454ms
ok 25 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 407ms
ok 26 don't get confused by input redirections in 405ms
ok 27 loads grammar and emits rewrite suggestion in 391ms
ok 28 invoking resholve without --interpreter prints an error in 731ms
ok 29 invoking resholve without path/inputs prints an error in 800ms
ok 30 invoking resholve with missing interpreter prints an error in 750ms
ok 31 invoking resholve with a relative interpreter prints an error in 759ms
ok 32 invoking resholve with a non-executable interpreter prints an error in 742ms
ok 33 invoking resholve without script's deps prints an error in 753ms
ok 34 ensure shebangs are identical in 732ms
ok 35 resholve resolves simple external dependency from command-line args in 778ms
ok 36 resholve resolves simple external dependency from stdin in 401ms
ok 37 path/inputs can be supplied with the inputs alias in 758ms
ok 38 only one of path/inputs can be supplied in 756ms
ok 39 resholve fails if target script isn't found in 765ms
ok 40 resholve fails with duplicate input scripts in 390ms
ok 41 resholve fails when scripts have untriaged dynamic elements in 761ms
ok 42 resholve fails when 'keep' directives are misformatted in 1105ms
ok 43 resholve fails when triage directive doesn't specify the right thing in 2844ms
ok 44 resholve succeeds when 1x 'keep' directives are correct in 1521ms
ok 45 resholve succeeds when 2x 'keep' directives are correct in 2092ms
ok 46 resholve accepts empty directives in 412ms
ok 47 don't resolve aliases without '--fix aliases' in 481ms
ok 48 inject before and after script in 775ms
ok 49 inject before/after in multiple scripts in 444ms
ok 50 fail with bad lore argument in 479ms
ok 51 accept good lore argument in 428ms
ok 52 'which' needs to be in RESHOLVE_PATH in 505ms
ok 53 Even in a function, 'which' needs to be in RESHOLVE_PATH in 403ms
ok 54 Absolute executable paths need exemptions in 397ms
ok 55 Even nested-executable paths need exemptions in 407ms
ok 56 Source, among others, needs an exemption for arguments containing variables in 422ms
ok 57 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 399ms
ok 58 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 406ms
ok 59 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 389ms
ok 60 Add an exemption with --keep <scope>:<name> in 401ms
ok 61 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 412ms
ok 62 'source' targets also need to be in RESHOLVE_PATH in 397ms
ok 63 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 478ms
ok 64 Has (naive) context-specific resolution rules in 531ms
ok 65 Has (rudimentary) support for resolving executable arguments in 571ms
ok 66 Can substitute a variable used as a command in 512ms
ok 67 modern resholve versions reject v1 files in 438ms
ok 68 exercise built-in syntax parsers in 1010ms
```
