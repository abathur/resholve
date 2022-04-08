# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
============================= resholve test suite ===================================
1..65
ok 1 verify warnings are thrown for quoted evals in 373ms
ok 2 verify --keep '$varname' allows dynamic commands in 318ms
ok 3 verify --fix '$varname:cmd' substitutes dynamic commands in 374ms
ok 4 can resolve a simple coproc in 335ms
ok 5 can't resolve a named coproc w/o upstream support :( in 574ms
ok 6 objects to unexempted absolute source paths in 311ms
ok 7 allows exempted absolute source paths in 314ms
ok 8 allow (but do not parse) --fake 'source:path' in 336ms
ok 9 allow (*and* do not parse) --keep 'source:path' + --fake 'source:path' in 526ms
ok 10 objects to unexempted tilde executable paths in 277ms
ok 11 allows exempted tilde executable paths in 272ms
ok 12 allows --fake executable in 288ms
ok 13 allows --fake function with colons in 308ms
ok 14 resolve abspath with --fix abspath in 300ms
ok 15 resolve fails without lore in 293ms
ok 16 resolve fails without assay in 272ms
ok 17 resolve fails with bad assay in 527ms
ok 18 resolve fails with overshooting assay wordnum in 555ms
ok 19 resolve fails with assay wordnum 0 in 288ms
ok 20 resolve fails with undershooting assay wordnum in 557ms
ok 21 resolve succeeds with assay in 297ms
ok 22 resolve commands mixed with varlike assignments in 306ms
ok 23 verify warnings are thrown for overridden builtins in 280ms
ok 24 Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo in 297ms
ok 25 don't get confused by input redirections in 275ms
ok 26 invoking resholve without --interpreter prints an error in 529ms
ok 27 invoking resholve without path/inputs prints an error in 516ms
ok 28 invoking resholve with missing interpreter prints an error in 521ms
ok 29 invoking resholve with a relative interpreter prints an error in 534ms
ok 30 invoking resholve with a non-executable interpreter prints an error in 532ms
ok 31 invoking resholve without script's deps prints an error in 541ms
ok 32 ensure shebangs are identical in 506ms
ok 33 resholve resolves simple external dependency from command-line args in 528ms
ok 34 resholve resolves simple external dependency from stdin in 286ms
ok 35 path/inputs can be supplied with the inputs alias in 557ms
ok 36 only one of path/inputs can be supplied in 507ms
ok 37 resholve fails if target script isn't found in 534ms
ok 38 resholve fails with duplicate input scripts in 273ms
ok 39 resholve fails when scripts have untriaged dynamic elements in 524ms
ok 40 resholve fails when 'keep' directives are misformatted in 700ms
ok 41 resholve fails when triage directive doesn't specify the right thing in 1539ms
ok 42 resholve succeeds when 1x 'keep' directives are correct in 689ms
ok 43 resholve succeeds when 2x 'keep' directives are correct in 1155ms
ok 44 resholve accepts empty directives in 262ms
ok 45 don't resolve aliases without '--fix aliases' in 318ms
ok 46 inject before and after script in 480ms
ok 47 fail with bad lore argument in 251ms
ok 48 accept good lore argument in 241ms
ok 49 'which' needs to be in RESHOLVE_PATH in 249ms
ok 50 Even in a function, 'which' needs to be in RESHOLVE_PATH in 255ms
ok 51 Absolute executable paths need exemptions in 247ms
ok 52 Even nested-executable paths need exemptions in 249ms
ok 53 Source, among others, needs an exemption for arguments containing variables in 244ms
ok 54 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 249ms
ok 55 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 247ms
ok 56 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 244ms
ok 57 Add an exemption with --keep <scope>:<name> in 244ms
ok 58 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 246ms
ok 59 'source' targets also need to be in RESHOLVE_PATH in 247ms
ok 60 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 276ms
ok 61 Has (naive) context-specific resolution rules in 333ms
ok 62 Has (rudimentary) support for resolving executable arguments in 353ms
ok 63 Can substitute a variable used as a command in 327ms
ok 64 modern resholve versions reject v1 files in 256ms
ok 65 exercise built-in syntax parsers in 424ms
```
