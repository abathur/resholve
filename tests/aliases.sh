shopt -s expand_aliases
alias "$1=__shellswain_init_command $1 $2"
alias "$1=event emit __shellswain_command_$1"

alias a=echo
#alias a1=ls
alias a2="ls"
alias b="echo blah"
alias "b1=echo blah"
alias b2="ls blah"
alias "b3=ls blah"
alias c='echo $SOURCE_DATE_EPOCH'
alias 'c1=echo $SOURCE_DATE_EPOCH'
alias c2='ls $SOURCE_DATE_EPOCH'
alias 'c3=ls $SOURCE_DATE_EPOCH'
alias d=a
alias e=b

function have_fun(){
	echo cool function $@
}
function half_fun(){
	command ls cool function $@
}

alias g=have_fun
alias g1=half_fun

function delay_definition(){
	echo "man, doing a lot of slow hard work to set this up rn"
	function delayed_definition(){
		echo about to run $@
		command ls about to run $@
		"$@"
	}
	alias ls=delayed_definition
}
alias ls=delay_definition

alias "$1=echo $1" # numeric varsubs currently exempted

# all together, now
alias a=echo a1=ls b="echo blah" "b1=echo blah" b2="ls blah" "b3=ls blah" c='echo $SOURCE_DATE_EPOCH' 'c1=echo $SOURCE_DATE_EPOCH' c2='ls $SOURCE_DATE_EPOCH' 'c3=ls $SOURCE_DATE_EPOCH' d=a e=b g=have_fun g1=half_fun ls=delay_definition

a
a1
a2
b
"b1"
b2
"b3"
c
'c1'
c2
'c3'
d
e
g
g1
ls

a sha512sum <<< hehe
a1 sha512sum <<< hehe
a2 sha512sum <<< hehe
b sha512sum <<< hehe
"b1" sha512sum <<< hehe
b2 sha512sum <<< hehe
"b3" sha512sum <<< hehe
c sha512sum <<< hehe
'c1' sha512sum <<< hehe
c2 sha512sum <<< hehe
'c3' sha512sum <<< hehe
d sha512sum <<< hehe
e sha512sum <<< hehe
g sha512sum <<< hehe
g1 sha512sum <<< hehe
ls sha512sum <<< hehe
