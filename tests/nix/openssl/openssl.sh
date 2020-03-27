openssl_sh() {
    set -x
    openssl version
    set +x
}

source shunit2
