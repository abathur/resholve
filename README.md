# resholved - a shell resolver? :)

Quick demonstration of a WIP Python script that leverages the Oil shell's parser to resolve some external shell script dependencies.

To run the demo:

```shell
git clone https://github.com/abathur/resholved.git
cd resholved
nix-shell --run "./demo"
```

But, in any case, here's the output:
```
$ nix-shell --run "./demo"
-- Resolving less_simple_success_a.sh ------------------------------------------
Resolver command: python2 resholver.py --allow PWD < less_simple_success_a.sh
--- less_simple_success_a.sh    2020-02-24 11:41:23.889812868 -0600
+++ /dev/fd/63  2020-02-24 11:59:04.331077380 -0600
@@ -1,5 +1,5 @@
 source simple_fail_a.sh
 which(){
    # resolves file here too
-   file "$@"
+   /nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file "$@"
 }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving less_simple_success_b.sh ------------------------------------------
Resolver command: python2 resholver.py --allow PWD < less_simple_success_b.sh
--- less_simple_success_b.sh    2020-02-24 11:40:54.977083198 -0600
+++ /dev/fd/63  2020-02-24 11:59:04.562325589 -0600
@@ -1,4 +1,4 @@
 # var isn't actually checked here
-file $HOME/simple_success_a.sh
+/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file $HOME/simple_success_a.sh
 # exempted by -allow PWD
 source $PWD/simple_success_a.sh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving simple_success_a.sh -----------------------------------------------
Resolver command: python2 resholver.py --allow PWD < simple_success_a.sh
--- simple_success_a.sh 2020-02-24 11:42:57.440617513 -0600
+++ /dev/fd/63  2020-02-24 11:59:04.706469688 -0600
@@ -1,2 +1,2 @@
 # resolves file from inputs
-file resholver.py
+/nix/store/ckaibpafaixfdnnf6d47qps7wd0107rl-file-5.37/bin/file resholver.py
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving simple_success_b.sh -----------------------------------------------
Resolver command: python2 resholver.py --allow PWD < simple_success_b.sh
--- simple_success_b.sh 2020-02-24 11:43:15.879785108 -0600
+++ /dev/fd/63  2020-02-24 11:59:04.877974130 -0600
@@ -1,2 +1,2 @@
 # resolves gettext from inputs
-source gettext.sh
+source /nix/store/8wn0zg0jx82kqh7aymnd860mkqvkib3s-gettext-0.19.8.1/bin/gettext.sh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving less_simple_fail_a.sh ---------------------------------------------
Original file:
> source simple_success_a.sh
> file(){
>   # no inputs provide which
>   command which "$@"
> }

Resolver command: python2 resholver.py --allow PWD < less_simple_fail_a.sh
Output:
    command which "$@"
            ^~~~~
[ stdinNone ]:4: Can't resolve command 'which' to a known function or executable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving less_simple_fail_b.sh ---------------------------------------------
Original file:
> /usr/bin/which resholver.py

Resolver command: python2 resholver.py --allow PWD < less_simple_fail_b.sh
Output:
  /usr/bin/which resholver.py
  ^~~~~~~~~~~~~~
[ stdinNone ]:1: Unexpected absolute command path (not supplied by a listed dependency). You should patch/substitute it.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving less_simple_fail_c.sh ---------------------------------------------
Original file:
> # fails because $HOME requires a dynamic parse
> # (I can resolve from a dictionary but haven't
> # seen a clear reason to do it...)
> # and isn't exempted with --allow HOME
> source $HOME/simple_success_a.sh

Resolver command: python2 resholver.py --allow PWD < less_simple_fail_c.sh
Output:
  source $HOME/simple_success_a.sh
         ^~~~~
[ stdinNone ]:5: Can't resolve 'source' with an argument that can't be statically parsed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving simple_fail_a.sh --------------------------------------------------
Original file:
> # no inputs provide which
> which resholver.py

Resolver command: python2 resholver.py --allow PWD < simple_fail_a.sh
Output:
  which resholver.py
  ^~~~~
[ stdinNone ]:2: Can't resolve command 'which' to a known function or executable
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Resolving simple_fail_b.sh --------------------------------------------------
Original file:
> # fails to resolve this (from inputs, or relative to directory)
> source doesnt_exist.sh

Resolver command: python2 resholver.py --allow PWD < simple_fail_b.sh
Output:
  source doesnt_exist.sh
         ^~~~~~~~~~~~~~~
[ stdinNone ]:2: Unable to resolve source target 'doesnt_exist.sh' to a known file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```
