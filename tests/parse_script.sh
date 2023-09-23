# TODO: shim this into the uname framework in helpers.bash (and vice-versa)
if [[ $(uname -s) == "Darwin" ]]; then
	script blah ls
else
	script -c "ls" blah
fi
