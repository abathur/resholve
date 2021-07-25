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

RESHOLVE_PATH="${RESHOLVE_PATH}:${PWD}/tests"

@test "'which' needs to be in RESHOLVE_PATH" {
  demo "which_simple.sh" <({
    status 3
  })
} <<CASES
resholve --interpreter $INTERP < which_simple.sh
CASES

@test "Even in a function, 'which' needs to be in RESHOLVE_PATH" {
  demo "command_in_function.sh" <(status 3)
} <<CASES
resholve --interpreter $INTERP < command_in_function.sh
CASES

@test "Absolute executable paths need exemptions" {
  demo "absolute_path.sh" <(status 5)
} <<CASES
resholve --interpreter $INTERP < absolute_path.sh
CASES

@test "Even nested-executable paths need exemptions" {
  demo "absolute_path_nested.sh" <(status 5)
} <<CASES
resholve --interpreter $INTERP < absolute_path_nested.sh
CASES

@test "Source, among others, needs an exemption for arguments containing variables" {
  demo "source_var_pwd.sh" <(status 6)
} <<CASES
resholve --interpreter $INTERP < source_var_pwd.sh
CASES

@test "Resolves unqualified 'file' to absolute path from RESHOLVE_PATH" {
  demo "file_simple.sh" <(status 0)
} <<CASES
resholve --interpreter $INTERP < file_simple.sh
CASES

# TODO: maybe it better illustrates to just collapse this test with the above (and tests 1 and 2)
@test "Even in a function, resolves unqualified 'file' to absolute path from RESHOLVE_PATH" {
  demo "file_in_function.sh" <(status 0)
} <<CASES
resholve --interpreter $INTERP < file_in_function.sh
CASES

@test "Only some commands ('source' but NOT 'file', here) are checked for variable arguments." {
  demo "file_home_source_pwd.sh" <(status 6)
} <<CASES
resholve --interpreter $INTERP < file_home_source_pwd.sh
CASES

@test "Add an exemption with --keep <scope>:<name>" {
  demo "file_home_source_pwd.sh" <(status 0)
} <<CASES
resholve --interpreter $INTERP --keep 'source:\$PWD' < file_home_source_pwd.sh
CASES

@test "Add an exemption with RESHOLVE_ALLOW="source:\$PWD"" {
  demo "file_home_source_pwd.sh" <(status 0)
} <<CASES
RESHOLVE_KEEP='source:\$PWD' resholve --interpreter $INTERP < file_home_source_pwd.sh
CASES

@test "'source' targets also need to be in RESHOLVE_PATH" {
  demo "source_missing_target.sh" <(status 4)
} <<CASES
resholve --interpreter $INTERP < source_missing_target.sh
CASES

@test "Resolves unqualified 'source' to absolute path from RESHOLVE_PATH" {
  demo "source_present_target.sh" <({
    status 0
    line -1 begins "# resholve: keep source:/nix/store/"
    line -1 contains "-gettext-"
    line -1 ends "/bin/gettext.sh"
  })
} <<CASES
resholve --interpreter $INTERP < source_present_target.sh
CASES

@test "Has (naive) context-specific resolution rules" {
  demo "alias_riddle.sh" <({
    status 0
    line 4 !contains "/nix/store"
    line 5 contains 'find="/nix/store'
    line 5 contains 'find2="/nix/store'
    line 7 !contains "/nix/store"
    line 9 !contains "/nix/store"
    line 10 contains "\file # the function!"
    line 11 contains "/nix/store"
    line 12 !contains "/nix/store"
    line 13 contains "/nix/store"
    line 14 contains "/nix/store"
    line 15 begins "### resholve directives (auto-generated)"
    # can't assert the ends; these get sorted
    # and the hash makes unstable :(
    line 16 equals "# resholve: fix aliases"
    line 17 begins "# resholve: keep /nix/store/"
    line 18 begins "# resholve: keep /nix/store/"
  })
} <<CASES
resholve --interpreter $INTERP --fix aliases < alias_riddle.sh
CASES

@test "Has (rudimentary) support for resolving executable arguments" {
  demo "nested_execer.sh" <({
    status 0
    line 5 contains '/bin/find $(type -p file) -name file -exec /nix/store/'
    line 5 contains "/bin/file {} +  "
  })
} <<CASES
resholve --interpreter $INTERP < nested_execer.sh
CASES

@test "Can substitute a variable used as a command" {
  demo "file_var.sh" <(status 0)
} <<CASES
resholve --interpreter $INTERP --fix '\$FILE_CMD:file' < file_var.sh
CASES
