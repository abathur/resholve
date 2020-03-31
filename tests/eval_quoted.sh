# next 2 commands ran fine
eval echo blah
eval "echo blah" # generates warning now

# next 2 were producing errors; gen warnings now
eval 'echo $HOME'
# eval 'echo $HOME'
#      ^
# [ stdinNone ]:3: Can't resolve command 'echo $HOME' to a known function or executable

eval '__ev.encode(){ local LC_ALL=C;REPLY=${1//_/_5f};' \
    "${__ev_jit-}"' [[ $REPLY != *[^_[:alnum:]]* ]] || __ev_jit "${REPLY//[_[:alnum:]]/}";}'

# eval '__ev.encode(){ local LC_ALL=C;REPLY=${1//_/_5f};'\
#      ^
# bashup.events:35: Can't resolve command '__ev.encode(){ local LC_ALL=C;REPLY=${1//_/_5f};' to a known function or executable
