exec "unset ${1%\[1]};${!1}"
env "unset ${1%\[1]};${!1}"
eval "unset ${1%\[1]};${!1}"
