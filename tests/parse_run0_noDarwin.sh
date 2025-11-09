run0 \
	-h --help \
	-V --version \
	   --no-ask-password \
	   --machine=CONTAINER \
	   --unit=UNIT \
	   --property=NAME=VALUE \
	   --description=TEXT \
	   --slice=SLICE \
	   --slice-inherit \
	-u USER --user=USER \
	-g GROUP --group=GROUP \
	   --nice=NICE \
	-D PATH --chdir=PATH \
	   --setenv=NAME \
	   --background=COLOR \
	   --pty \
	   --pipe \
	   --shell-prompt-prefix=PREFIX \
	ls

run0 \
	-h --help \
	-V --version \
	   --no-ask-password \
	   --machine=CONTAINER \
	   --unit=UNIT \
	   --property=NAME=VALUE \
	   --description=TEXT \
	   --slice=SLICE \
	   --slice-inherit \
	-u USER --user=USER \
	-g GROUP --group=GROUP \
	   --nice=NICE \
	-D PATH --chdir=PATH \
	   --setenv=NAME \
	   --background=COLOR \
	   --pty \
	   --pipe \
	   --shell-prompt-prefix=PREFIX \
	-- \
	ls

run0 -- run0 -- ls
run0 run0 ls
run0
run0 -u ls ls
