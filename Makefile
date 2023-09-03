#! /usr/bin/env make
#export PATH := $(shell nix-shell -p nix coreutils gnused groff util-linux --run 'echo $$PATH')
export PATH := $(shell nix-shell make.nix --run 'echo $$PATH')

.PHONY: apologeez ci clean update

apologeez:
	@echo Sorry--the Makefile is a lie. I just use this for dev tasks atm.
	@echo See README.md / https://github.com/abathur/resholve

all: apologeez
install: apologeez
uninstall: apologeez

.local : *.nix setup.cfg setup.py test.sh demo tests/* resholve.1 resholve _resholve/*
	touch .local


result-ci: .local
	@echo Building ci.nix
	@nix-build --out-link result-ci ci.nix
	@touch result-ci result-ci/* || true # TODO: fails on MU

ci: result-ci

result-quick: .local
	@echo Building quick.nix
	@nix-build --out-link result-quick quick.nix
	@touch result-quick result-quick/* || true # TODO: fails on MU

quick: result-quick

clean:
	rm .local result-ci result-quick docs/README.nixpkgs.md

result-ci/test.txt result-ci/demo.txt result-ci/nix-demo.txt: result-ci

timings.md: bits/timings.md.pre bits/timings.md.post result-ci/test.txt
	@echo Building timings.md
	@cat bits/timings.md.pre \
		result-ci/test.txt \
		bits/timings.md.post \
		> timings.md

demos.md: bits/demos.md.pre bits/demos.md.mid bits/demos.md.post result-ci/demo.txt result-ci/nix-demo.txt
	@echo Building demos.md
	@cat bits/demos.md.pre \
		result-ci/demo.txt \
		bits/demos.md.mid \
		result-ci/nix-demo.txt \
		bits/demos.md.post \
		| sed -E 's@/nix/store/[a-z0-9]{32}-@/nix/store/...-@g' > demos.md

resholve.1: docs/manpage.wwst docs/manpage.css docs/content.wwst
	@echo Building manpage
	@wordswurst $< > $@

docs/README.nixpkgs.md: docs/markdown.wwst docs/markdown.css docs/content.wwst docs/examples/*.nix
	@echo "Building Nixpkgs README (markdown)"
	@wordswurst $< > $@

docs/%.css: docs/%.scss
	@echo Sassing $@ from $<
	@sassc --omit-map-comment $< $@

# -dAD=l is left alignment per groff_man.7.gz
docs/resholve.1.txt: resholve.1
	@echo Building plain-text copy of manpage
	@groff -m mdoc -dAD=l -T utf8 $< | ansifilter > $@

_resholve/strings.py: docs/strings.wwst docs/strings.css docs/content.wwst
	@echo Wursting $@ from $<
	@wordswurst $< > $@

update: timings.md demos.md docs/resholve.1.txt docs/README.nixpkgs.md
