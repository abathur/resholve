setup() {
    {
        TEST_TMP="$(mktemp -d)"
        cp tests/*.{bats,bash,sh} "$TEST_TMP"/ > /dev/null
        pushd "$TEST_TMP"
    } > /dev/null
}
teardown() {
    {
        popd > /dev/null
    } > /dev/null
}

# status <num>
_expect_status() {
    if [[ $status != "$1" ]]; then
        return 1
    fi
}

# line (-)<num> equals|contains|begins|ends "value"
_expect_line() {
    lineno=$1 line=${lines[$1]} kind=$2
    case $kind in
        equals)
            if [[ $line == "$3" ]]; then
                return 0
            else
                echo "  expected line $lineno:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        contains)
            if [[ $line == *"$3"* ]]; then
                return 0
            else
                echo "  expected line $lineno:"
                echo "     '$3'"
                echo "  actual:"
                echo "     '$line'"
                return 1
            fi
            ;;
        begins)
            if [[ $line == "$3"* ]]; then
                return 0
            else
                echo "  expected line $lineno to begin with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
        ends)
            if [[ $line == *"$3" ]]; then
                return 0
            else
                echo "  expected line $lineno to end with:"
                echo "     '$3'"
                echo "  actual line:"
                echo "     '$line'"
                return 1
            fi
            ;;
    esac
    # shouldn't get here
    echo "unexpected input: $@"
    return 2
}

status() {
    echo "_expect_status ${@@Q}"
}

line() {
    echo "_expect_line ${@@Q}"
}

# cases are on STDIN
# expectations in fd passed as arg 1
require() {
    mapfile _cases
    # TODO: I'd like to print numbers by these in the TAP output, but contrary to the docs they're leaking into the pretty-print output. Worth trying after the next bats version bump.
    # casenum=0
    for case in "${_cases[@]}"; do
        # ((casenum = casenum + 1))#
        run eval "$case"
        # echo "#  ${BATS_TEST_NUMBER}-${casenum}: ${case%$'\n'}" >&3
        printf "status: %s\n" $status
        printf "output:\n%s" "$output"
        if ! source "$1"; then

            eval "$case"
            false
        fi

    done
}
