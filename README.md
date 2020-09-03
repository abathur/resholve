# resholve - Resolve references to external dependencies in shell scripts

![Test](https://github.com/abathur/resholve/workflows/Test/badge.svg)

resholve [WIP] generates a copy of a shell script with external dependencies
resolved to absolute paths. (It accomplishes this by leveraging the [Oil](https://github.com/oilshell/oil) shell's parser).

Here's a rundown of where things stand:

- It is functional (and working for a living), but I intend to seek out some bike-shedding over how things are named, so the APIs may change. From this point, I'll try to make sure I summarize those in the [changelog](CHANGELOG.md).
- I don't anticipate declaring an initial release until I feel like the option API/names are more stable/systematic.
- Learning is self-serve for now. You can see how to use the Nix integration in [ci.nix](ci.nix). General script usage is hopefully clear enough from the tests and demo.
- My short-term goal is to support packaging shell projects for the [Nix package manager](https://nixos.org/nix/) (and hopefully getting this support into Nixpkgs). As such, the current build process depends on Nix.
- The script itself isn't Nix-specific--it can resolve dependencies from whatever paths you specify. *If you're interested in using resholve without Nix, I'll appreciate contributions that build out traditional Python build support.*


## Demos

I've built two different demos to illustrate what you can do with resholve--one for resholve itself, and the other shows the Nix integration.

If you'd like to run them yourself (you'll need Nix installed), start with:

```shell
git clone https://github.com/abathur/resholve.git
cd resholve
```

### resholve demo
This demo runs a handful of commands on a set of test `.sh` scripts (you can see the files in [tests/](tests/), though not all files there are used in the demo) to illustrate what happens when resholve successfully resolves dependencies, and what happens when it doesn't.

- The top separator line shows what command was run and its exit status.
- A status > 0 indicates the script couldn't be resolved. The body of the case report quotes the original file, and any feedback the command gives about why it can't resolve the script.
- A status == 0 indicates the script was resolved. The body of the case report shows a diff of the input script, and the resolved output.

To run this demo yourself:

```shell
nix-shell --run "./demo"
```

The demo output is colored for easier reading, but I've included an example of the output below as well:

```
$ nix-shell --run "./demo"
1..12

--[ resholve < which_simple.sh (exit: 3) ]-------------------------------------

Original:
>>> # no inputs provide which
>>> which resholve

Output:
>>>   which resholve
>>>   ^~~~~
>>> [ stdinNone ]:2: Can't resolve command 'which' to a known function or executable

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 1 'which' needs to be in RESHOLVE_PATH

--[ resholve < command_in_function.sh (exit: 3) ]------------------------------

Original:
>>> source file_simple.sh
>>> file() {
>>>     # no inputs provide which
>>>     command which "$@"
>>> }

Output:
>>>       command which "$@"
>>>               ^~~~~
>>> [ stdinNone ]:4: Can't resolve command 'which' to a known function or executable

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 2 Even in a function, 'which' needs to be in RESHOLVE_PATH

--[ resholve < absolute_path.sh (exit: 5) ]------------------------------------

Original:
>>> /usr/bin/which resholve

Output:
>>>   /usr/bin/which resholve
>>>   ^~~~~~~~~~~~~~
>>> [ stdinNone ]:1: Unexpected absolute command path (not supplied by a listed dependency). You should patch/substitute it.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 3 Absolute executable paths need exemptions

--[ resholve < source_var_pwd.sh (exit: 6) ]-----------------------------------

Original:
>>> # fails because $PWD requires a dynamic parse
>>> # (I can resolve from a dictionary but haven't
>>> # seen a clear reason to do it...)
>>> # and isn't exempted with --allow source:PWD
>>> source $PWD/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with a dynamic argument

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 4 Source, among others, needs an exemption for arguments containing variables

--[ resholve < file_simple.sh (exit: 0) ]--------------------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,5 @@
>>>  # resolves file from inputs
>>> -file resholve
>>> +/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file resholve
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 5 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH

--[ resholve < file_in_function.sh (exit: 0) ]---------------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  source which_simple.sh
>>>  which() {
>>>      # resolves file here too
>>> -    file "$@"
>>> +    /nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file "$@"
>>>  }
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file
>>> +# resholve: allow resholved_inputs:which_simple.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 6 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH

--[ resholve < file_home_source_pwd.sh (exit: 6) ]-----------------------------

Original:
>>> # $HOME not blocking here; vars currently only checked in:
>>> #   alias command eval exec source|. sudo
>>> file $HOME/file_simple.sh
>>> # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>> source $PWD/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with a dynamic argument

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 7 Only some commands ('source' but NOT 'file', here) are checked for variable arguments.

--[ resholve --allow source:PWD < file_home_source_pwd.sh (exit: 0) ]----------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo
>>> -file $HOME/file_simple.sh
>>> +/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file
>>> +# resholve: allow source:PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 8 Add an exemption with --allow <scope>:<name>

--[ RESHOLVE_ALLOW="source:PWD" resholve < file_home_source_pwd.sh (exit: 0) ]-

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo
>>> -file $HOME/file_simple.sh
>>> +/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file
>>> +# resholve: allow source:PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 9 Add an exemption with RESHOLVE_ALLOW=source:PWD

--[ resholve < source_missing_target.sh (exit: 7) ]----------------------------

Original:
>>> # fails to resolve this (from inputs, or relative to directory)
>>> source doesnt_exist.sh

Output:
>>>   source doesnt_exist.sh
>>>          ^~~~~~~~~~~~~~~
>>> [ stdinNone ]:2: Unable to resolve source target 'doesnt_exist.sh' to a known file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 10 'source' targets also need to be in RESHOLVE_PATH

--[ resholve < source_present_target.sh (exit: 0) ]----------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,5 @@
>>>  # resolves gettext from inputs
>>> -source gettext.sh
>>> +source /nix/store/7y6vn8wr00zwkcnv830qjkra37gvd11p-gettext-0.20.1/bin/gettext.sh
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/7y6vn8wr00zwkcnv830qjkra37gvd11p-gettext-0.20.1/bin/gettext.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 11 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH

--[ resholve --resolve-aliases < alias_riddle.sh (exit: 0) ]-------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,14 +1,18 @@
>>>  # don't try to run me; I'll probably crash or hang or something
>>>  # I'm just a succinct test for complex resolution logic...
>>>  alias file="file -n" # the function
>>> -alias find="find -H" find2="find -P" # external!
>>> +alias find="/nix/store/w4vj07i9cq1g9vg9y0l44ijy80k9hlwz-findutils-4.7.0/bin/find -H" find2="/nix/store/w4vj07i9cq1g9vg9y0l44ijy80k9hlwz-findutils-4.7.0/bin/find -P" # external!
>>>  
>>>  function file(){
>>>     file -n # the alias :P
>>>  }
>>>  
>>>  file # I'm the alias
>>> -command file # external
>>> +command /nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file # external
>>>  
>>>  find # alias
>>> -command find # external
>>> +command /nix/store/w4vj07i9cq1g9vg9y0l44ijy80k9hlwz-findutils-4.7.0/bin/find # external
>>> +
>>> +### resholve directives (auto-generated)
>>> +# resholve: allow resholved_inputs:/nix/store/w4vj07i9cq1g9vg9y0l44ijy80k9hlwz-findutils-4.7.0/bin/find
>>> +# resholve: allow resholved_inputs:/nix/store/zp3m4d9mgri3knc7k59r3hvf93d0j69f-file-5.38/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 12 Has (naive) context-specific resolution rules
```

### Nix demo

This demo illustrates how to use resholve in Nix to compose a set of modules together. You can see the Nix code for the modules in [ci.nix](ci.nix), and their shell scripts in [tests/nix](tests/nix/). The modules are:

- `shunit2` - This re-builds [Nixpkgs existing shunit2 package](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/misc/shunit2/default.nix) in a resolved form. This module demonstrates the Nix API for telling resholve that some violations are okay.
- `test_module1` - Depends on the jq and libressl executables, and on test_module2.
- `test_module2` - Depends on the openssl executable, and the shunit2 module/shell library.
- `test_module3` - Depends on test_module1.

This demo (which is just a shell script executing with `set -x` enabled around points of interest) is a little harder to follow, so I'll run down the points of interest before throwing you in:

- The demo runs by executing conjure.sh with a clean environment (i.e `env -i $(type -p conjure.sh)`). *It is not depending on its run-time environment!*
- Before any output begins, `conjure.sh` (test_module3) sources `libressl.sh` (test_module1), which sources `openssl.sh` (test_module2), which sources `shunit2`. *Everything is in one shell namespace when the test begins.*
- When `shunit2` is sourced, it automatically collects and runs functions named test_*.
- `type jq openssl` demonstrates that the jq and openssl executables aren't on the PATH. *Dependencies declared for one module/script aren't leaking into others!*
- Both `openssl.sh` and `libressl.sh` invoke `openssl`, but *because the scripts were separately resolved by Nix and resholve, `openssl.sh` correctly invokes `OpenSSL 1.1.1d  10 Sep 2019`, while `libressl.sh` correctly invokes `LibreSSL 2.9.2`!* 

```
============================= resholve Nix demo ===============================
test_future_perfection
nothing up my sleeve
+++++ type jq openssl
/nix/store/s54waamz4rkxhc2rq2wyrgad4jlp6gbm-testmod3/bin/conjure.sh: line 6: type: jq: not found
/nix/store/s54waamz4rkxhc2rq2wyrgad4jlp6gbm-testmod3/bin/conjure.sh: line 6: type: openssl: not found
+++++ set +x
test_openssl
+++++ /nix/store/i6rnpwfhwdd7wjazfxk07rnzr58jba43-openssl-1.1.1d-bin/bin/openssl version
OpenSSL 1.1.1d  10 Sep 2019
+++++ set +x
test_libressl
+++++ /nix/store/i8v85aggdsgk0c8558l1dq2q43scgs15-jq-1.6-bin/bin/jq -n --arg greeting world '{"hello":$greeting}'
{
  "hello": "world"
}
+++++ /nix/store/xm7dyydpdyx5ica5msbp1adzc6i06acq-libressl-2.9.2-bin/bin/openssl version
LibreSSL 2.9.2
+++++ set +x

Ran 3 tests.

OK
```

I've made a [gist](https://gist.github.com/abathur/937877b1321f443400e0779314f2e02c) with this output, the resolved shell scripts, and the Nix code for each module. You can also see this output in the [CI logs](https://github.com/abathur/resholve/runs/816065777?check_suite_focus=true#step:5:5732) (though I leave out the resolved shunit2, since it's fairly long).

This test is currently tied into the CI run (which includes the unit tests and both demos), so the best way to run it is:

```shell
nix-build ci.nix
```

## Known Gaps & Edge Cases

Don't expect this to be exhaustive any time soon--but I'll try to acknowledge gaps and edge cases that resholve can't handle as I discover them. Please open an issue if you find a new one (but--do look for an existing issue first)

The main areas I'm currently aware of:

- resholve makes no attempt to perform deep/recursive analysis on commands that run other commands. Plainly, resholve *does* try to verify that "blah" in `command blah` resolves to a real command--but it won't resolve it if you do something cute like `command command command blah`. 
- resholve doesn't have robust handling of variables that get executed like commands (this includes things like `eval $variable` and `"$run_as_command"` and `$GIT_COMMAND status`). There's some room for improvement here, but I also want to manage expectations--my goal is for resholve to handle low-hanging fruit.
    - there's a first-level complication about seeing-through the variables themselves, here--and then a second-level issue with seeing-through double-quoted strings
- fc -s has interesting behavior that makes it hard to account for
    - if I run `ls /tmp` and then `echo blah` and then `fc -s 'ls'`, it'll re-run that previous ls command
        - if resholve rewrites ls to an absolute path, the fc -s command won't work as expected unless we also expand the ls inside the fc command
    - if I run `ls /tmp` and then `fc -s tmp=sbin`, it'll run `ls /sbin`; if I then run `fc -s ls=stat`, it runs `stat /sbin`
        - accounting for and triaging this will be very hard; there are no strict semantics here; we can substitute arbitrary text which could be executable names or arguments or even just parts of them; we'd have to be very explicitly parsing things out, or maybe extracting them into a mock test and running it, to know what to do
    - For now this is unaddressed. It probably makes the most sense to just raise a warning about not handling fc and link to a doc or issue about it, but I'm inclined to put this off until someone asks about it.
