openssl_sh() {
    set -x
    openssl version
    invokeme
    libexec/invokeme
    set +x
}
alias blah=openssl

source shunit2
