source submodule/helper.sh

libressl_sh() {
    set -x
    jq -n --arg greeting world '{"hello":$greeting}'
    openssl version
    set +x
}

just_being_helpful

source openssl.sh
