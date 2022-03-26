fargs(){
	echo "nice $(type -ap file) you got there"
}

echo wert | find $(type -p file) -name file -exec file {} +  # resolve 1st/~last
echo wert | fargs file # resolve none
echo wert | exec find file # resolve 2nd
echo wert | xargs file # resolve both

builtin source gettext.sh # resolve last
builtin command . gettext.sh # resolve last
builtin command -v . gettext.sh # resolve last

echo wert | exec >&2 # resolve none

# semi-nonsense, but should resolve bash, gettext, file, bash, file
bash \
	-c "source gettext.sh" \
	"bop" \
	-c "command file" \
	-c "bash -c file"

if type -p find; then
	type -p find
elif ! type -p find; then
	! type -p find
fi
