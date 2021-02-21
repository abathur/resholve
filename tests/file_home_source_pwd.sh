# $HOME not blocking here; vars currently only checked in:
#   alias command eval exec source|. sudo env
file $HOME/file_simple.sh
# PWD needs exemption: --keep source:PWD or RESHOLVE_KEEP='source:PWD'
source $PWD/file_simple.sh
