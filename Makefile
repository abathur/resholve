#! /usr/bin/env make
export PATH := $(shell nix develop .#make --command sh -c 'echo $$makeInputs')

.PHONY: apologeez ci clean update # lint

apologeez:
	@echo Sorry--the Makefile is a lie. I just use this for dev tasks atm.
	@echo See README.md / https://github.com/abathur/resholve

all: apologeez
install: apologeez
uninstall: apologeez


result-ci: *.nix flake.lock nixpkgs/*.nix setup.cfg setup.py test.sh demo tests/* resholve.1 resholve _resholve/*
	@echo Running Nix CI tests
	@nix build .#ci --out-link nix-result-ci --print-build-logs
	@mkdir -p result-ci
	@install -m 644 nix-result-ci/* result-ci/

ci: result-ci

clean:
	rm nix-result-ci result-ci/* nixpkgs/README.md

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

# use a touchfile; store will have old timestamps
nixpkgs_source.touch: flake.lock
	@echo linking nixpkgs source into $@
	@nix build --out-link nixpkgs_source "$$(nix eval .#nixpkgs_source --raw)"
	@touch nixpkgs_source.touch

nixpkgs/README.md: docs/markdown.wwst docs/markdown.css docs/content.wwst docs/examples/*.nix nixpkgs_source.touch
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

update: timings.md demos.md docs/resholve.1.txt nixpkgs/README.md

# lint: lint-sass # lint-nix

# lint-nix:
# 	nixpkgs-fmt

# lint-sass: docs/*.scss
# 	scss-lint $<
