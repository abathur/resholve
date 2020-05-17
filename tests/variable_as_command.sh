GIT_PROGRAM="git"
LS_PROGRAM="ls -la"
STAT_HERE="stat ."
ELSEWHERE=~/
STAT_ELSEWHERE="stat $ELSEWHERE"

$GIT_PROGRAM status
"$GIT_PROGRAM status"
"$GIT_PROGRAM" status
"${GIT_PROGRAM} status"
"${GIT_PROGRAM}" status
# '$GIT_PROGRAM status' # actual error
# '$GIT_PROGRAM' status # actual error
# '${GIT_PROGRAM} status' # actual error
# '${GIT_PROGRAM}' status # actual error

$LS_PROGRAM
"$LS_PROGRAM"
"${LS_PROGRAM}"
# '$LS_PROGRAM' # actual error
# '${LS_PROGRAM}' # actual error

$LS_PROGRAM /
"$LS_PROGRAM /"
"$LS_PROGRAM" /
"${LS_PROGRAM} /"
"${LS_PROGRAM}" /
# '$LS_PROGRAM /' # actual error
# '$LS_PROGRAM' / # actual error
# '${LS_PROGRAM} /' # actual error
# '${LS_PROGRAM}' / # actual error

$LS_PROGRAM $HOME
"$LS_PROGRAM $HOME"
"$LS_PROGRAM" $HOME
"${LS_PROGRAM} $HOME"
"${LS_PROGRAM}" $HOME
# '$LS_PROGRAM $HOME' # actual error
# '$LS_PROGRAM' $HOME # actual error
# '${LS_PROGRAM} $HOME' # actual error
# '${LS_PROGRAM}' $HOME # actual error

$STAT_HERE
"$STAT_HERE"
"${STAT_HERE}"
# '$STAT_HERE' # actual error
# '${STAT_HERE}' # actual error

$STAT_ELSEWHERE
"$STAT_ELSEWHERE"
"${STAT_ELSEWHERE}"
# '$STAT_ELSEWHERE' # actual error
# '${STAT_ELSEWHERE}' # actual error

$0
${0}
"$0"
"${0}"
# '$0' # actual error
# '${0}' # actual error

$1
${1}
"$1"
"${1}"
# '$1' # actual error
# '${1}' # actual error

$@
${@}
"$@"
"${@}"
# '$@' # actual error
# '${@}' # actual error
