# don't try to run me; I'll probably crash or hang or something
# I'm just a succinct test for complex resolution logic...
alias file="file -n" # the function
alias find="find -H" find2="find -P" # external!

function file(){
	file -n # the alias :P
}

file # I'm the alias
\file # the function!
command file # external

find # alias
\find # external
command find # external
