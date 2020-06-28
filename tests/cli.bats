# This suite focuses on exercising basic usage of the resholver command, including
# - positional parameters
# - flags
# - environment variables
# - stdin/out
#
# It also demonstrates which invocations are equivalent.
#
# Conceptually, there's a lot of overlap between this task and what's done in demo.bats.
# But they're separated out for now so that we can run the demo differently to better
# capture its output and present it as an illustration of what resholved is for. In the
# longer run, better formal documentation may make it possible to merge cases covered
# by the demo into this file. In any case, if you add something to the demo--make sure
# it is also covered here. But not the inverse--the demo doesn't need to cover the same
# exact ground as thoroughly as this suite.

load helpers


@test "invoking resholver without RESHOLVE_PATH prints an error" {
  unset RESHOLVE_PATH
  require <({
    status 1
    line -1 equals "AssertionError: RESHOLVE_PATH must be set"
  })
} <<CASES
resholver < file_simple.sh
resholver file_simple.sh
CASES

@test "invoking resholver without script deps prints an error" {
  RESHOLVE_PATH=''
  require <({
    status 3
    line -1 contains "Can't resolve command 'file' to a known function or executable"
  })
} <<CASES
resholver < file_simple.sh
resholver file_simple.sh
CASES

@test "resholver resolves simple external dependency from command-line args" {
  require <({
    status 0
    line -1 contains "wrote "
  })
} <<CASES
resholver file_simple.sh
resholver file_simple.sh source_present_target.sh
CASES

@test "resholver resolves simple external dependency from stdin" {

  require <({
    status 0
    line -1 begins "# resholved: allow resholved_inputs:/nix/store"
    line -1 contains "-file-"
    line -1 ends "/bin/file"
  })
} <<CASES
resholver < file_simple.sh
CASES

@test "resholver fails if target script isn't found" {

  require <({
    status 2
    line -1 begins "Aborting due to missing file: '/hopenot/file_simple.sh'"
  })
} <<CASES
resholver /hopenot/file_simple.sh
resholver file_simple.sh /hopenot/file_simple.sh
CASES

@test "resholver fails with duplicate input scripts" {

  require <({
    status 2
    line 1 equals "Aborting due to duplicate script targets."
  })
} <<CASES
resholver file_simple.sh source_present_target.sh source_present_target.sh
CASES

@test "resholver fails when scripts have dynamic elements that aren't 'allowed'" {

  require <({
    status 6
    line -1 contains "Can't resolve 'source' with a dynamic argument"
  })
} <<CASES
resholver source_var_pwd.sh
resholver source_home_pwd.sh
CASES

@test "resholver fails when 'allow' directives are misformatted" {

  require <({
    status 2
    line -1 contains "should be a scope:var pair"
  })
} <<CASES
resholver --allow source PWD source_var_pwd.sh
resholver --allow PWD source_var_pwd.sh
resholver < source_var_pwd_bad_annotation.sh
CASES

@test "resholver fails when 'allow' directive doesn't specify the right thing" {

  require <({
    status 6
    line -1 contains "Can't resolve 'source' with a dynamic argument"
  })
} <<CASES
resholver --allow command:PWD < source_var_pwd.sh
RESHOLVE_ALLOW='command:PWD' resholver < source_var_pwd.sh
resholver --allow source:HOME < source_var_pwd.sh
RESHOLVE_ALLOW='source:HOME' resholver < source_var_pwd.sh
resholver < source_var_pwd_misannotated.sh
resholver --allow source:PWD < source_home_pwd.sh
RESHOLVE_ALLOW='source:PWD' resholver < source_home_pwd.sh
CASES

@test "resholver succeeds when 1x 'allow' directives are correct" {

  require <({
    status 0
    line -2 equals "### resholved directives (auto-generated)"
    line -1 equals "# resholved: allow source:PWD"
  })
} <<CASES
resholver --allow source:PWD < source_var_pwd.sh
RESHOLVE_ALLOW='source:PWD' resholver < source_var_pwd.sh
resholver < source_var_pwd_annotated.sh
CASES

@test "resholver succeeds when 2x 'allow' directives are correct" {

  require <({
    status 0
    line -3 equals "### resholved directives (auto-generated)"
    # Note: the output order of these in-doc directives is sorted; it *should* be idempotent for equivalent inputs!
    line -2 equals "# resholved: allow source:HOME"
    line -1 equals "# resholved: allow source:PWD"
  })
} <<CASES
resholver --allow source:PWD --allow source:HOME < source_home_pwd.sh
RESHOLVE_ALLOW='source:PWD source:HOME' resholver < source_home_pwd.sh
RESHOLVE_ALLOW='source:PWD' resholver --allow source:HOME < source_home_pwd.sh
RESHOLVE_ALLOW='source:PWD' resholver < source_home_pwd_annotated_incomplete.sh
resholver --allow source:PWD < source_home_pwd_annotated_incomplete.sh
CASES

@test "Don't resolve aliases without --resolve-aliases" {
  require <({
    status 0
    line 3 !contains "/nix/store"
    line 4 !contains 'find="/nix/store'
    line 4 !contains 'find2="/nix/store'
    line 6 !contains "/nix/store"
    line 8 !contains "/nix/store"
    line 9 contains "/nix/store"
    line 10 !contains "/nix/store"
    line 11 contains "/nix/store"
    line 12 equals "### resholved directives (auto-generated)"
    # can't assert the ends; these get sorted
    # and the hash makes unstable :(
    line 13 begins "# resholved: allow resholved_inputs:/nix/store/"
    line 14 begins "# resholved: allow resholved_inputs:/nix/store/"
  })
} <<CASES
resholver < alias_riddle.sh
CASES
