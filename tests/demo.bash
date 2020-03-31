load helpers

# python args: char, color, label=""
rule() {
    if [[ -n $3 ]]; then
        local msg="\033[0m\033[1;$2m $3 \033[0m"
        printf -v _width "\033[0m\033[1;$2m%80s\033[0m" && echo -en "${_width// /${1--}}" && echo -e "\r\033[2C$msg"
    else
        printf -v _width "\033[0m\033[1;$2m%80s\033[0m" && echo -en "${_width// /${1--}}\n"
    fi
}
quote() {
    echo "$1"
    while IFS= read text; do
        printf "\033[34m>>>\033[0m %s\n" "$text"
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
                    diff --color=always --label "original" --label "resolved" --unified=-1 "$1" - <<< "$output" | quote "Diff:"
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
