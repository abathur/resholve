load helpers
# bats doesn't have runtime test generation/parameterization yet, so we'll just brute-force all of these

# TODO:
# - ~xfail for things like sed/awk/dc...? I guess these can also be normal tests, or maybe dedicated "handler" tests?
# - run system paths? sudo?
# - run once for each of multiple valid packages/binaries? generic shells, gnutar/bsdtar

@test "exercise built-in syntax parsers" {
	parsers
}
