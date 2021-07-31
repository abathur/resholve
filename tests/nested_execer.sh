fargs(){
	echo "nice $(type -ap file) you got there"
}

echo wert | find $(type -p file) -name file -exec file {} +  # resolve 1st/~last
echo wert | fargs file # resolve none
echo wert | exec find file # resolve 2nd
echo wert | xargs file # resolve both

builtin source gettext.sh # resolve last
builtin command . gettext.sh # resolve last

exec >&2 # resolve none
