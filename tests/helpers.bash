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

parsers() {
    cat parse_*.sh > parsed.sh
    resholve --interpreter none --path "${PKG_PARSED}:${PKG_COREUTILS}" < parsed.sh > resolved.sh
    bash -xe resolved.sh
}
