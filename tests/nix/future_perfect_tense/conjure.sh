#!/usr/bin/env bash
test_future_perfection() {
    echo "nothing up my sleeve"

    {
        set -x
        type jq openssl
        set +x
    }
    return 0
}

test_openssl() {
    openssl_sh
}

test_libressl() {
    libressl_sh
}

source libressl.sh
