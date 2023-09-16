# This suite collects tests that exercise the code around in-file directives
# *ideally* this suite should exhaust the directive options of each major
# version of the directive syntax. While the main point of this is going
# forward, the aspiration is for it to be good enough that you could run an
# older version of resholve against this suite to learn how compatible it is
# with newer versions of the format.

bats_load_library bats-require
load helpers

@test "modern resholve versions reject v1 files" {
  require <({
    status 2
    line 1 ends "with *native* directive fmt v3 parsing directive fmt v1"
    line -1 contains "error:  While parsing resholve directives already in this script, I encountered an 'allow' directive from resholve(d)'s pre-history. The program no longer supports this directive format--you'll have to re-resholve this script with a modern version."
  })
} <<CASES
resholve --interpreter $INTERP directives_v1.sh
CASES

# TODO: exhaustive v2 directive case
