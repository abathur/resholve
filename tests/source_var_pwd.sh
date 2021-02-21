# fails because $PWD requires a dynamic parse
# (I can resolve from a dictionary but haven't
# seen a clear reason to do it...)
# and isn't exempted with --keep source:PWD
source $PWD/file_simple.sh
source ${PWD}/file_simple.sh
