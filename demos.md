# Demos
I've built two different demos to illustrate what you can do with resholve--one for resholve itself, and the other shows the Nix integration.

If you'd like to run them yourself (you'll need Nix installed), start with:

```shell
git clone https://github.com/abathur/resholve.git
cd resholve
```

## resholve demo
This demo runs a handful of commands on a set of test `.sh` scripts (you can see the files in [tests/](tests/), though not all files there are used in the demo) to illustrate what happens when resholve successfully resolves dependencies, and what happens when it doesn't.

- The top separator line shows what command was run and its exit status.
- A status > 0 indicates the script couldn't be resolved. The body of the case report quotes the original file, and any feedback the command gives about why it can't resolve the script.
- A status == 0 indicates the script was resolved. The body of the case report shows a diff of the input script, and the resolved output.

To run this demo yourself:

```shell
nix-shell --run "./demo"
```

The demo output is colored for easier reading, but I've included an example of the output below as well:

```shell
$ nix-shell --run "./demo"
1..14

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < which_simple.sh (exit: 3) ]

Original:
>>> # no inputs provide which
>>> which resholve

Output:
>>>   which resholve
>>>   ^~~~~
>>> [ stdinNone ]:3: Couldn't resolve command 'which'

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 1 'which' needs to be in RESHOLVE_PATH in 305ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < command_in_function.sh (exit: 3) ]

Original:
>>> source file_simple.sh
>>> file() {
>>>     # no inputs provide which
>>>     command which "$@"
>>> }

Output:
>>>       command which "$@"
>>>               ^~~~~
>>> [ stdinNone ]:5: Couldn't resolve command 'which'
>>> #!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>> source /private/tmp/nix-build-resholve-test.drv-1/resholved/tests/file_simple.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 2 Even in a function, 'which' needs to be in RESHOLVE_PATH in 312ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < absolute_path.sh (exit: 5) ]

Original:
>>> /usr/bin/which resholve

Output:
>>>   /usr/bin/which resholve
>>>   ^~~~~~~~~~~~~~
>>> [ stdinNone ]:2: Unexpected absolute command path (not supplied by a listed dependency).
>>> 
>>> Next step: patch/substitute it.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 3 Absolute executable paths need exemptions in 285ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < absolute_path_nested.sh (exit: 5) ]

Original:
>>> find . -name resholve -exec /usr/bin/file {} +

Output:
>>>   find . -name resholve -exec /usr/bin/file {} +
>>>                               ^~~~~~~~~~~~~
>>> [ stdinNone ]:2: Unexpected absolute command path (not supplied by a listed dependency).
>>> 
>>> Next step: patch/substitute it.
>>> #!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>> /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 4 Even nested-executable paths need exemptions in 287ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < source_var_pwd.sh (exit: 6) ]

Original:
>>> # fails because $PWD requires a dynamic parse
>>> # (I can resolve from a dictionary but haven't
>>> # seen a clear reason to do it...)
>>> # and isn't exempted with --keep source:PWD
>>> source $PWD/file_simple.sh
>>> source ${PWD}/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:6: Can't resolve dynamic argument in 'source'

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 5 Source, among others, needs an exemption for arguments containing variables in 292ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < file_simple.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,6 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  # resolves file from inputs
>>> -file resholver
>>> +/nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file resholver
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 6 Resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 287ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < file_in_function.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,10 @@
>>> -source which_simple.sh
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>> +source /private/tmp/nix-build-resholve-test.drv-1/resholved/tests/which_simple.sh
>>>  which() {
>>>      # resolves file here too
>>> -    file "$@"
>>> +    /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file "$@"
>>>  }
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file
>>> +# resholve: keep source:/private/tmp/nix-build-resholve-test.drv-1/resholved/tests/which_simple.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 7 Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH in 292ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < file_home_source_pwd.sh (exit: 6) ]

Original:
>>> # $HOME not blocking here; vars currently only checked in:
>>> #   alias command eval exec source|. sudo env
>>> file $HOME/file_simple.sh
>>> # PWD needs exemption: --keep source:PWD or RESHOLVE_KEEP='source:PWD'
>>> source $PWD/file_simple.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:6: Can't resolve dynamic argument in 'source'

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 8 Only some commands ('source' but NOT 'file', here) are checked for variable arguments. in 287ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash --keep 'source:$PWD' < file_home_source_pwd.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,10 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo env
>>> -file $HOME/file_simple.sh
>>> +/nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --keep source:PWD or RESHOLVE_KEEP='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file
>>> +# resholve: keep source:$PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 9 Add an exemption with --keep <scope>:<name> in 295ms

--[ RESHOLVE_KEEP='source:$PWD' resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < file_home_source_pwd.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,10 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  # $HOME not blocking here; vars currently only checked in:
>>>  #   alias command eval exec source|. sudo env
>>> -file $HOME/file_simple.sh
>>> +/nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file $HOME/file_simple.sh
>>>  # PWD needs exemption: --keep source:PWD or RESHOLVE_KEEP='source:PWD'
>>>  source $PWD/file_simple.sh
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file
>>> +# resholve: keep source:$PWD

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 10 Add an exemption with RESHOLVE_ALLOW=source:$PWD in 297ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < source_missing_target.sh (exit: 4) ]

Original:
>>> # fails to resolve this (from inputs, or relative to directory)
>>> source doesnt_exist.sh

Output:
>>>   source doesnt_exist.sh
>>>          ^~~~~~~~~~~~~~~
>>> [ stdinNone ]:3: Unable to resolve source target 'doesnt_exist.sh' to a known file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 11 'source' targets also need to be in RESHOLVE_PATH in 291ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < source_present_target.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,3 +1,7 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  # resolves gettext from inputs
>>> -source gettext.sh
>>> -. gettext.sh
>>> +source /nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh
>>> +. /nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep source:/nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 12 Resolves unqualified 'source' to absolute path from RESHOLVE_PATH in 322ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash --fix aliases < alias_riddle.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,16 +1,22 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  # don't try to run me; I'll probably crash or hang or something
>>>  # I'm just a succinct test for complex resolution logic...
>>>  alias file="file -n" # the function
>>> -alias find="find -H" find2="find -P" # external!
>>> +alias find="/nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find -H" find2="/nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find -P" # external!
>>>  
>>>  function file(){
>>>  	file -n # the alias :P
>>>  }
>>>  
>>>  file # I'm the alias
>>>  \file # the function!
>>> -command file # external
>>> +command /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file # external
>>>  
>>>  find # alias
>>> -\find # external
>>> -command find # external
>>> +\/nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find # external
>>> +command /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find # external
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: fix aliases
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file
>>> +# resholve: keep /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 13 Has (naive) context-specific resolution rules in 342ms

--[ resholve --interpreter /nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash < nested_execer.sh (exit: 0) ]

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,13 +1,20 @@
>>> +#!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
>>>  fargs(){
>>>  	echo "nice $(type -ap file) you got there"
>>>  }
>>>  
>>> -echo wert | find $(type -p file) -name file -exec file {} +  # resolve 1st/~last
>>> +echo wert | /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find $(type -p file) -name file -exec /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file {} +  # resolve 1st/~last
>>>  echo wert | fargs file # resolve none
>>> -echo wert | exec find file # resolve 2nd
>>> -echo wert | xargs file # resolve 1st
>>> +echo wert | exec /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find file # resolve 2nd
>>> +echo wert | /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/xargs /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file # resolve 1st
>>>  
>>> -builtin source gettext.sh # resolve last
>>> -builtin command . gettext.sh # resolve last
>>> +builtin source /nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh # resolve last
>>> +builtin command . /nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh # resolve last
>>>  
>>>  exec >&2 # resolve none
>>> +
>>> +### resholve directives (auto-generated) ## format_version: 2
>>> +# resholve: keep /nix/store/77p3lid93i5xjgdi9vkj3zqcpf2zddlw-file-5.39/bin/file
>>> +# resholve: keep /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/find
>>> +# resholve: keep /nix/store/l81ywa20y740zq5i0015jg3744g5qz3l-findutils-4.7.0/bin/xargs
>>> +# resholve: keep source:/nix/store/sc4qmg3bk9rw0cyz3yzncyy3kaala7cv-gettext-0.21/bin/gettext.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
ok 14 Has (rudimentary) support for resolving executable arguments in 334ms
```

## Nix demo

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

It is currently tied into the CI run, so for now you'll have to run the whole thing if you want to see it locally (sorry!):

```shell
nix-build ci.nix
```

I'll try to keep these up-to-date, but if you suspect this file is outdated you can also find the output at the end of the main phase of resholve's latest successful [weekly scheduled CI run](https://github.com/abathur/resholve/actions?query=branch%3Amaster+event%3Aschedule+is%3Asuccess).

```shell
$ nix-build ci.nix
much help
test_future_perfection
nothing up my sleeve
+++++ type jq openssl
/nix/store/9h7mcdkr70yw5zffn90pjjmn603az8rp-testmod3-unreleased/bin/conjure.sh: line 7: type: jq: not found
/nix/store/9h7mcdkr70yw5zffn90pjjmn603az8rp-testmod3-unreleased/bin/conjure.sh: line 7: type: openssl: not found
+++++ set +x
test_openssl
+++++ /nix/store/gdrl09cxsbml1gdb0dqkjb11i1s36183-openssl-1.1.1k-bin/bin/openssl version
OpenSSL 1.1.1k  25 Mar 2021
+++++ set +x
test_libressl
+++++ /nix/store/bm7qa6rl8r5jzmhp306qjgzxcik8yhaa-jq-1.6-bin/bin/jq -n --arg greeting world '{"hello":$greeting}'
{
  "hello": "world"
}
+++++ /nix/store/vczmlczp2qz4pgawya8qh8sj7064jcva-libressl-3.2.5-bin/bin/openssl version
LibreSSL 3.2.5
+++++ set +x

Ran 3 tests.

OK
───────┬────────────────────────────────────────────────────────────────────────
       │ File: /nix/store/9h7mcdkr70yw5zffn90pjjmn603az8rp-testmod3-unreleased/bin/conjure.sh
───────┼────────────────────────────────────────────────────────────────────────
   1   │ #!/nix/store/pcjan45rssdn01cxx3sjg70avjg6c3ni-bash-4.4-p23/bin/bash
   2   │ test_future_perfection() {
   3   │     echo "nothing up my sleeve"
   4   │ 
   5   │     {
   6   │         set -x
   7   │         type jq openssl
   8   │         set +x
   9   │     }
  10   │     return 0
  11   │ }
  12   │ 
  13   │ test_openssl() {
  14   │     openssl_sh
  15   │ }
  16   │ 
  17   │ test_libressl() {
  18   │     libressl_sh
  19   │ }
  20   │ 
  21   │ source /nix/store/1fz0bxlmjm92i7rza9hy9z953jnjvrbm-testmod1-unreleased/bin/libressl.sh
  22   │ 
  23   │ ### resholve directives (auto-generated) ## format_version: 2
  24   │ # resholve: keep source:/nix/store/1fz0bxlmjm92i7rza9hy9z953jnjvrbm-testmod1-unreleased/bin/libressl.sh
  25   │ 
───────┴────────────────────────────────────────────────────────────────────────
───────┬────────────────────────────────────────────────────────────────────────
       │ File: /nix/store/9d0xaa20pq72i6wbp48smazabnfwmdq8-testmod2-unreleased/bin/openssl.sh
───────┼────────────────────────────────────────────────────────────────────────
   1   │ openssl_sh() {
   2   │     set -x
   3   │     /nix/store/gdrl09cxsbml1gdb0dqkjb11i1s36183-openssl-1.1.1k-bin/bin/openssl version
   4   │     set +x
   5   │ }
   6   │ alias blah=/nix/store/gdrl09cxsbml1gdb0dqkjb11i1s36183-openssl-1.1.1k-bin/bin/openssl
   7   │ 
   8   │ source /nix/store/lllz9bg5w4hf8ssxwklbr5rbzx1zp1v2-shunit2-2019-08-10/bin/shunit2
   9   │ 
  10   │ ### resholve directives (auto-generated) ## format_version: 2
  11   │ # resholve: fix aliases
  12   │ # resholve: keep /nix/store/gdrl09cxsbml1gdb0dqkjb11i1s36183-openssl-1.1.1k-bin/bin/openssl
  13   │ # resholve: keep source:/nix/store/lllz9bg5w4hf8ssxwklbr5rbzx1zp1v2-shunit2-2019-08-10/bin/shunit2
  14   │ 
───────┴────────────────────────────────────────────────────────────────────────
───────┬────────────────────────────────────────────────────────────────────────
       │ File: /nix/store/1fz0bxlmjm92i7rza9hy9z953jnjvrbm-testmod1-unreleased/bin/libressl.sh
───────┼────────────────────────────────────────────────────────────────────────
   1   │ source /nix/store/1fz0bxlmjm92i7rza9hy9z953jnjvrbm-testmod1-unreleased/submodule/helper.sh
   2   │ 
   3   │ libressl_sh() {
   4   │     set -x
   5   │     /nix/store/bm7qa6rl8r5jzmhp306qjgzxcik8yhaa-jq-1.6-bin/bin/jq -n --arg greeting world '{"hello":$greeting}'
   6   │     /nix/store/vczmlczp2qz4pgawya8qh8sj7064jcva-libressl-3.2.5-bin/bin/openssl version
   7   │     set +x
   8   │ }
   9   │ 
  10   │ just_being_helpful
  11   │ 
  12   │ source /nix/store/9d0xaa20pq72i6wbp48smazabnfwmdq8-testmod2-unreleased/bin/openssl.sh
  13   │ 
  14   │ ### resholve directives (auto-generated) ## format_version: 2
  15   │ # resholve: keep /nix/store/bm7qa6rl8r5jzmhp306qjgzxcik8yhaa-jq-1.6-bin/bin/jq
  16   │ # resholve: keep /nix/store/vczmlczp2qz4pgawya8qh8sj7064jcva-libressl-3.2.5-bin/bin/openssl
  17   │ # resholve: keep source:/nix/store/1fz0bxlmjm92i7rza9hy9z953jnjvrbm-testmod1-unreleased/submodule/helper.sh
  18   │ # resholve: keep source:/nix/store/9d0xaa20pq72i6wbp48smazabnfwmdq8-testmod2-unreleased/bin/openssl.sh
  19   │ 
───────┴────────────────────────────────────────────────────────────────────────
```
