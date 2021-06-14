#! /usr/bin/env make

.PHONY: apologeez ci clean update

apologeez:
	@echo Sorry--the Makefile is a lie. I just use this for dev tasks atm.
	@echo See README.md / https://github.com/abathur/resholve

all: apologeez
install: apologeez
uninstall: apologeez

.local : resholve *.nix test.sh demo tests/*
	touch .local


result-ci: .local
	@echo Building ci.nix
	@nix-build --out-link result-ci ci.nix
	@touch result-ci || true # TODO: fails on MU

ci: result-ci

clean:
	rm .local result-ci

result-ci/test.txt result-ci/demo.txt result-ci/nix-demo.txt: result-ci

timings.md: bits/timings.md.pre bits/timings.md.post result-ci/test.txt
	cat bits/timings.md.pre \
		result-ci/test.txt \
		bits/timings.md.post \
		> timings.md

demos.md: bits/demos.md.pre bits/demos.md.mid bits/demos.md.post result-ci/demo.txt result-ci/nix-demo.txt
	cat bits/demos.md.pre \
		result-ci/demo.txt \
		bits/demos.md.mid \
		result-ci/nix-demo.txt \
		bits/demos.md.post \
		> demos.md

resholve.1: resholve.1.in
	printf ".Dd %(%B %d, %Y)T\n" && \
		grep -v -E "\.Dd(\s|$)" resholve.1.in \
		> resholve.1

resholve.1.txt: resholve.1
	groff -m mdoc -T utf8 resholve.1 | col -bx > resholve.1.txt

update: timings.md demos.md resholve.1.txt
