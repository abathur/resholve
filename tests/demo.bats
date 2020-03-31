# This suite is used to generate a quick, pragmatic introduction to what resholved does
# and how to invoke it.
#
# This could probably be a screencast or more formal documentation but at least early
# on, making this behavior testable and adding it to the normal test CI runs will help
# ensure that the contract the demo provides as starter documentation stays valid, and
# that it's easy to notice when the demo needs to be updated.
#
# In the longer run, this may go away if formal documentation can do a better job of
# communicating what it communicates, and everything it tests explicitly/implicitly is
# well-tested elsewhere.
load demo

@test "'which' needs to be in RESHOLVE_PATH" {
  demo "which_simple.sh" <({
    status 3
  })
} <<CASES
resholver < which_simple.sh
CASES

@test "Even in a function, 'which' needs to be in RESHOLVE_PATH" {
  demo "command_in_function.sh" <(status 3)
} <<CASES
resholver < command_in_function.sh
CASES

@test "Absolute executable paths need exemptions" {
  demo "absolute_path.sh" <(status 5)
} <<CASES
resholver < absolute_path.sh
CASES

@test "Source, among others, needs an exemption for arguments containing variables" {
  demo "source_var_pwd.sh" <(status 6)
} <<CASES
resholver < source_var_pwd.sh
CASES

@test "Resolves unqualified 'file' to absolute path from RESHOLVE_PATH" {
  demo "file_simple.sh" <(status 0)
} <<CASES
resholver < file_simple.sh
CASES

# TODO: maybe it better illustrates to just collapse this test with the above (and tests 1 and 2)
@test "Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH" {
  demo "file_in_function.sh" <(status 0)
} <<CASES
resholver < file_in_function.sh
CASES

@test "Only some commands ('source' but NOT 'file', here) are checked for variable arguments." {
  demo "file_home_source_pwd.sh" <(status 6)
} <<CASES
resholver < file_home_source_pwd.sh
CASES

@test "Add an exemption with --allow <scope>:<name>" {
  demo "file_home_source_pwd.sh" <(status 0)
} <<CASES
resholver --allow source:PWD < file_home_source_pwd.sh
CASES

@test "Add an exemption with RESHOLVE_ALLOW="source:PWD"" {
  demo "file_home_source_pwd.sh" <(status 0)
} <<CASES
RESHOLVE_ALLOW="source:PWD" resholver < file_home_source_pwd.sh
CASES

@test "'source' targets also need to be in RESHOLVE_PATH" {
  demo "source_missing_target.sh" <(status 7)
} <<CASES
resholver < source_missing_target.sh
CASES

@test "Resolves unqualified 'source' to absolute path from RESHOLVE_PATH" {
  demo "source_present_target.sh" <({
    status 0
    line -1 begins "# resholved: allow resholved_inputs:/nix/store/"
    line -1 contains "-gettext-"
    line -1 ends "/bin/gettext.sh"
  })
} <<CASES
resholver < source_present_target.sh
CASES
