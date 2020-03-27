libressl_sh() {
    set -x
    jq -n --arg greeting world '{"hello":$greeting}'
    openssl version
    set +x
}

source openssl.sh
