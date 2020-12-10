# This suite collects tests that exercise the code around in-file directives
# *ideally* this suite should exhaust the directive options of each major
# version of the directive syntax. While the main point of this is going
# forward, the aspiration is for it to be good enough that you could run an
# older version of resholve against this suite to learn how compatible it is
# with newer versions of the format.

load helpers

@test "modern resholve versions reject v1 files" {
  require <({
    status 2
  })
} <<CASES
resholve --interpreter $INTERP directives_v1_shunit2.sh
CASES

# TODO: exhaustive v2 directive case
