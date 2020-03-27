# $HOME not blocking here; vars currently only checked in:
#   alias command eval exec source|. sudo
file $HOME/file_simple.sh
# PWD needs exemption: --allow source:PWD or ALLOWED_VARSUBS='source:PWD'
source $PWD/file_simple.sh
