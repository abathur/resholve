#! /usr/bin/env bash
set -o errexit
# we package oil and force a namespace on it;
# we want some sense that its packages aren't
# leaking out
# note: tentatively disabled in favor of nix
# import check
# python tests/test_oil_namespace.py

# and run all bats tests
bats --timing tests
