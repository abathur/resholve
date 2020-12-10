openssl_sh() {
    set -x
    openssl version
    set +x
}
alias blah=openssl

source shunit2
