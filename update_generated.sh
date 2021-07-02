#!/usr/bin/env bash
#!/usr/bin/env bash
update_timings(){
	cat - result/test.txt <<'EOF'
# Test Timings
Experimenting with keeping a copy of test runs with timing information
to start building up a loose record of performance over time. Not sure
if it'll stick.

```text
EOF

echo '```'
} > timings.md

gen_demo(){
	cat - result/demo.txt <<'EOF'
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
EOF

	cat - result/nix-demo.txt <<'EOF'
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
EOF

echo '```'
}

update_demo(){
	gen_demo | sed -E 's@/nix/store/[a-z0-9]{32}-@/nix/store/...-@g'
} > demos.md

update_manual(){
	if [[ resholve.1.in -nt resholve.1 ]] ; then
		{
			printf ".Dd %(%B %d, %Y)T\n"
			grep -v -E "\.Dd(\s|$)" resholve.1.in
		} > resholve.1
		groff -m mdoc -T utf8 resholve.1 | col -bx > resholve.1.txt
	fi
}

if [[ -n "$1" ]]; then
	while [[ -n "$1" ]]; do
		update_$1
		shift
	done
else
	nix-build ci.nix
	update_timings
	update_demo
	update_manual
fi


# gen plaintext manpage?
