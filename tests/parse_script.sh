if [[ $(uname -s) == "Darwin" ]]; then
	script blah ls
else
	script -c "ls" blah
fi
