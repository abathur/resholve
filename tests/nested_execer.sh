fargs(){
	echo "nice $(type -ap file) you got there"
}

echo wert | find $(type -p file) -name file -exec file {} +  # should resolve first/last
echo wert | fargs file # resolve none
echo wert | exec find file # resolve first
