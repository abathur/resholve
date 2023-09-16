bats_load_library bats-require
load helpers

_cols="${COLUMNS:-80}"

# $1=char $2=color (code) $3=label
rule() {
    if [[ -n $3 ]]; then
        # length of incoming message
        let msglen=${#3}

        # incoming message + 6 (4 for "-- [", 2 for " ]")
        let inlaylen=msglen+6

        # make a column-appropriate number of spaces
        printf -v _width "%*s" "$_cols"

        # replace space w/ char ($1)
        _width="${_width// /${1}}"

        # echo
        # - the format open,
        # - 2 chars from the separator
        # - the message ($3)
        # - the rest of the separator
        # - format close
        echo -en "\033[0m\033[1;$2m${_width:0:2}[ ${3} ]${_width:inlaylen}\033[0m\n\n"
    else
        printf -v _width "\033[0m\033[1;$2m%*s\033[0m" "$_cols" && echo -en "${_width// /${1--}}\n"
    fi
}
quote() {
    echo "$1"
    while IFS= read -r text; do
        printf "\033[34m>>>\033[0m %s\n" "${text}"
    done
    echo ""
}

if [[ -n $RESHOLVE_DEMO ]]; then
    # cases are on STDIN
    # expectations in fd passed as arg 1
    demo() {
        mapfile _cases
        ret=0
        for case in "${_cases[@]}"; do
            run eval "$case"

            # strip tail linebreak;
            # TODO: probably a cheaper way to do thihs
            casename="$(echo $case)"
            {
                echo ""
                if [[ $status != 0 ]]; then
                    # failed to resolve
                    rule "-" "35" "$casename (exit: $status)"
                    quote "Original:" < "$1"
                    quote "Output:" <<< "$output"
                    rule "^" "35"
                else
                    # resolved fine
                    rule "-" "36" "$casename (exit: $status)"
                    # We'd like to use something like MAX/all/infinite lines
                    # of context, which we could express with -1 up through
                    # diffutils 3.7, but 3.8 has broken this. Will use
                    # probably-too-big instead...
                    diff --color=always --label "original" --label "resolved" --unified=10000 "$1" - <<< "$output" | quote "Diff:"
                    rule "^" "36"
                fi
            } >&3 # FD3 is where bats lets us write to term

            source "$2"
        done
    }
else
    demo() {
        # discard arg 1, only useful in demo mode
        shift
        require "$@"
    }
fi
