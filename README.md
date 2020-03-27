# resholved - a shell resolver? :)

Quick demonstration of a WIP Python script that leverages the Oil shell's parser to resolve some external shell script dependencies.

To run the demo:

```shell
git clone https://github.com/abathur/resholved.git
cd resholved
nix-shell --run "pytest demo"
```

But, in any case, here's the output (you can also see [a colored version in the Travis build logs](https://travis-ci.org/github/abathur/resholved/jobs/662618611#L3086):
```
$ nix-shell --run "pytest demo"
demo/test_demo.py 
-------command_in_function.sh unresolved (status: 3)--------

Original:
>>> source file_simple.sh
>>> file() {
>>>     # no inputs provide which
>>>     command which "$@"
>>> }

Command: resholver < command_in_function.sh

Output:
>>>       command which "$@"
>>>               ^~~~~
>>> [ stdinNone ]:4: Can't resolve command 'which' to a known function or executable

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

----------absolute_path.sh unresolved (status: 5)-----------

Original:
>>> /usr/bin/which resholver.py

Command: resholver < absolute_path.sh

Output:
>>>   /usr/bin/which resholver.py
>>>   ^~~~~~~~~~~~~~
>>> [ stdinNone ]:1: Unexpected absolute command path (not supplied by a listed dependency). You should patch/substitute it.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

----------source_var_pwd.sh unresolved (status: 6)----------

Original:
>>> # fails because $PWD requires a dynamic parse
>>> # (I can resolve from a dictionary but haven't
>>> # seen a clear reason to do it...)
>>> # and isn't exempted with --allow PWD
>>> source $PWD/file_simple.sh

Command: resholver < source_var_pwd.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with an argument that can't be statically parsed

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

----------file_in_function.sh resolved (status: 0)----------
Command: resholver < file_in_function.sh

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,5 +1,8 @@
>>>  source which_simple.sh
>>>  which() {
>>>      # resolves file here too
>>> -    file "$@"
>>> +    /nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file "$@"
>>>  }
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-------file_home_source_pwd.sh unresolved (status: 6)-------

Original:
>>> # $HOME not blocking here; vars currently only checked in:
>>> #   alias command eval exec source|. sudo
>>> file $HOME/file_simple.sh
>>> # PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
>>> source $PWD/file_simple.sh

Command: resholver < file_home_source_pwd.sh

Output:
>>>   source $PWD/file_simple.sh
>>>          ^~~~
>>> [ stdinNone ]:5: Can't resolve 'source' with an argument that can't be statically parsed

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--------file_home_source_pwd.sh resolved (status: 0)--------
Command: resholver --allow source:PWD < file_home_source_pwd.sh

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

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

--------file_home_source_pwd.sh resolved (status: 0)--------
Command: resholver < file_home_source_pwd.sh

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

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-----------which_simple.sh unresolved (status: 3)-----------

Original:
>>> # no inputs provide which
>>> which resholver.py

Command: resholver < which_simple.sh

Output:
>>>   which resholver.py
>>>   ^~~~~
>>> [ stdinNone ]:2: Can't resolve command 'which' to a known function or executable

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

------source_missing_target.sh unresolved (status: 7)-------

Original:
>>> # fails to resolve this (from inputs, or relative to directory)
>>> source doesnt_exist.sh

Command: resholver < source_missing_target.sh

Output:
>>>   source doesnt_exist.sh
>>>          ^~~~~~~~~~~~~~~
>>> [ stdinNone ]:2: Unable to resolve source target 'doesnt_exist.sh' to a known file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

------------file_simple.sh resolved (status: 0)-------------
Command: resholver < file_simple.sh

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,5 @@
>>>  # resolves file from inputs
>>> -file resholver.py
>>> +/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file resholver.py
>>> +
>>> +### resholved directives (auto-generated)
>>> +# resholved: allow resholved_inputs:/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-------source_present_target.sh resolved (status: 0)--------
Command: resholver < source_present_target.sh

Diff:
>>> --- original
>>> +++ resolved
>>> @@ -1,2 +1,2 @@
>>>  # resolves gettext from inputs
>>> -source gettext.sh
>>> +source /nix/store/8wn0zg0jx82kqh7aymnd860mkqvkib3s-gettext-0.19.8.1/bin/gettext.sh

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```
