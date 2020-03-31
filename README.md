# resholved - Resolve references to external dependencies in shell scripts

This WIP Python script generates a copy of a shell script with external dependencies
resolved to absolute paths. (It accomplishes this by leveragnig the [Oil](https://github.com/oilshell/oil) shell's parser).

Here's a rundown of where things stand:

- This is functional, but I intend to seek out some bike-shedding over how things are named, so the APIs may change. From this point, I'll try to make sure I summarize those.
- Learning is self-serve for now. You can see how to use the Nix integration in [ci.nix](ci.nix). General script usage is hopefully clear enough from the tests and demo.
- My short-term goal is to support packaging shell projects for the [Nix package manager](https://nixos.org/nix/) (and hopefully getting this support into Nixpkgs). As such, the current build process depends on Nix.
- The script itself isn't Nix-specific--it can resolve dependencies from whatever paths you specify. *If you're interested in using resholved without Nix, I'll appreciate contributions that build out traditional Python build support.*


## Demos

I've built two different demos to illustrate what you can do with resholved--one for resholved itself, and the other shows the Nix integration.

If you'd like to run them yourself (you'll need Nix installed), start with:

```shell
git clone https://github.com/abathur/resholved.git
cd resholved
```

### resholved demo
This demo runs a handful of commands on a set of test `.sh` scripts (you can see the files in [tests/](tests/), though not all files there are used in the demo) to illustrate what happens when resholved successfully resolves dependencies, and what happens when it doesn't.

- The top separator line shows what command was run and its exit status.
- A status > 0 indicates the script couldn't be resolved. The body of the case report quotes the original file, and any feedback the command gives about why it can't resolve the script.
- A status == 0 indicates the script was resolved. The body of the case report shows a diff of the input script, and the resolved output.

To run this demo yourself:

```shell
nix-shell --run "./demo"
```

I've included a copy of the output below, but you can also see a colored version [in the CI build log](https://travis-ci.org/github/abathur/resholved/jobs/669433171#L3844):

```
$ nix-shell --run "./demo"
1..11

--[ resholver < which_simple.sh (exit: 3) ]-------------------------------------

Original:
>>> # no inputs provide which
>>> which resholver

Output:
>>>   which resholver
>>>   ^~~~~
>>> [ stdinNone ]:2: Can't resolve command 'which' to a known function or executable

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 1 'which' needs to be in RESHOLVE_PATH

--[ resholver < command_in_function.sh (exit: 3) ]------------------------------

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

--[ resholver < absolute_path.sh (exit: 5) ]------------------------------------

Original:
>>> /usr/bin/which resholver

Output:
>>>   /usr/bin/which resholver
>>>   ^~~~~~~~~~~~~~
>>> [ stdinNone ]:1: Unexpected absolute command path (not supplied by a listed dependency). You should patch/substitute it.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 3 Absolute executable paths need exemptions

--[ resholver < source_var_pwd.sh (exit: 6) ]-----------------------------------

Original:
>>> # fails because $PWD requires a dynamic parse
>>> # (I can resolve from a dictionary but haven't
>>> # seen a clear reason to do it...)
>>> # and isn't exempted with --allow source:PWD
>>> source $PWD/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with an argument that can't be statically parsed

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 4 Source, among others, needs an exemption for arguments containing variables

--[ resholver < file_simple.sh (exit: 0) ]--------------------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,5 @@
>>>  # resolves file from inputs
>>> -file resholver
>>> +/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file resholver
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 5 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH

--[ resholver < file_in_function.sh (exit: 0) ]---------------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  source which_simple.sh
>>>  which() {
>>>      # resolves file here too
>>> -    file "$@"
>>> +    /nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file "$@"
>>>  }
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file
>>> +# resholved: allow resholved_inputs:which_simple.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 6 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH

--[ resholver < file_home_source_pwd.sh (exit: 6) ]-----------------------------

Original:
>>> # $HOME not blocking here; vars currently only checked in:
>>> #   alias command eval exec source|. sudo
>>> file $HOME/file_simple.sh
>>> # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>> source $PWD/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with an argument that can't be statically parsed

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 7 Only some commands ('source' but NOT 'file', here) are checked for variable arguments.

--[ resholver --allow source:PWD < file_home_source_pwd.sh (exit: 0) ]----------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo
>>> -file $HOME/file_simple.sh
>>> +/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file
>>> +# resholved: allow source:PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 8 Add an exemption with --allow <scope>:<name>

--[ RESHOLVE_ALLOW="source:PWD" resholver < file_home_source_pwd.sh (exit: 0) ]-

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,9 @@
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo
>>> -file $HOME/file_simple.sh
>>> +/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file
>>> +# resholved: allow source:PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 9 Add an exemption with RESHOLVE_ALLOW=source:PWD

--[ resholver < source_missing_target.sh (exit: 7) ]----------------------------

Original:
>>> # fails to resolve this (from inputs, or relative to directory)
>>> source doesnt_exist.sh

Output:
>>>   source doesnt_exist.sh
>>>          ^~~~~~~~~~~~~~~
>>> [ stdinNone ]:2: Unable to resolve source target 'doesnt_exist.sh' to a known file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 10 'source' targets also need to be in RESHOLVE_PATH

--[ resholver < source_present_target.sh (exit: 0) ]----------------------------

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,5 @@
>>>  # resolves gettext from inputs
>>> -source gettext.sh
>>> +source /nix/store/8wn0zg0jx82kqh7aymnd860mkqvkib3s-gettext-0.19.8.1/bin/gettext.sh
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/8wn0zg0jx82kqh7aymnd860mkqvkib3s-gettext-0.19.8.1/bin/gettext.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 11 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH
```

### Nix demo

This demo illustrates how to use resholved in Nix to compose a set of modules together. You can see the Nix code for the modules in [ci.nix](ci.nix), and their shell scripts in [tests/nix](tests/nix/). The modules are:

- `shunit2` - This re-builds [Nixpkgs existing shunit2 package](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/misc/shunit2/default.nix) in a resolved form. This module demonstrates the Nix API for telling resholved that some violations are okay.
- `test_module1` - Depends on the jq and libressl executables, and on test_module2.
- `test_module2` - Depends on the openssl executable, and the shunit2 module/shell library.
- `test_module3` - Depends on test_module1.

This demo (which is just a shell script executing with `set -x` enabled around points of interest) is a little harder to follow, so I'll run down the points of interest before throwing you in:

- The demo runs by executing conjure.sh with a clean environment (i.e `env -i $(type -p conjure.sh)`). *It is not depending on its run-time environment!*
- Before any output begins, `conjure.sh` (test_module3) sources `libressl.sh` (test_module1), which sources `openssl.sh` (test_module2), which sources `shunit2`. *Everything is in one shell namespace when the test begins.*
- When `shunit2` is sourced, it automatically collects and runs functions named test_*.
- `type jq openssl` demonstrates that the jq and openssl executables aren't on the PATH. *Dependencies declared for one module/script aren't leaking into others!*
- Both `openssl.sh` and `libressl.sh` invoke `openssl`, but *because the scripts were separately resolved by Nix and resholved, `openssl.sh` correctly invokes `OpenSSL 1.1.1d  10 Sep 2019`, while `libressl.sh` correctly invokes `LibreSSL 2.9.2`!* 

```
============================= resholver Nix demo ===============================
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

I've made a [gist](https://gist.github.com/abathur/937877b1321f443400e0779314f2e02c) with this output, the resolved shell scripts, and the Nix code for each module. You can also see this output in the [CI logs](https://travis-ci.org/github/abathur/resholved/jobs/667731225#L4329) (though I leave out the resolved shunit2, since it's fairly long).

This test is currently tied into the CI run (which includes the unit tests and both demos), so the best way to run it is:

```shell
nix-build ci.nix
```
