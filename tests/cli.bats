# This suite focuses on exercising basic usage of the resholve command, including
# - positional parameters
# - flags
# - environment variables
# - stdin/out
#
# It also demonstrates which invocations are equivalent.
#
# Conceptually, there's a lot of overlap between this task and what's done in demo.bats.
# But they're separated out for now so that we can run the demo differently to better
# capture its output and present it as an illustration of what resholve is for. In the
# longer run, better formal documentation may make it possible to merge cases covered
# by the demo into this file. In any case, if you add something to the demo--make sure
# it is also covered here. But not the inverse--the demo doesn't need to cover the same
# exact ground as thoroughly as this suite.

load helpers

@test "invoking resholve without --interpreter prints an error" {
  require <({
    status 2
    line -1 equals "resholve: error: argument --interpreter is required"
  })
} <<CASES
resholve < file_simple.sh
resholve file_simple.sh
CASES

@test "invoking resholve without path/inputs prints an error" {
  unset RESHOLVE_PATH
  require <({
    status 2
    line -1 equals "resholve: error: one of the arguments --path --inputs is required"
  })
} <<CASES
resholve --interpreter /usr/bin/env < file_simple.sh
resholve --interpreter none file_simple.sh
CASES

@test "invoking resholve with missing interpreter prints an error" {
  require <({
    status 1
    line -1 equals "AssertionError: Interpreter must exist or be the string 'none'"
  })
} <<CASES
resholve --interpreter /blah < file_simple.sh
resholve --interpreter /blah file_simple.sh
CASES

@test "invoking resholve with a relative interpreter prints an error" {
  require <({
    status 1
    line -1 equals "AssertionError: Interpreter path must be absolute"
  })
  # just using a random relative script as interp
} <<CASES
resholve --interpreter aliases.sh < file_simple.sh
resholve --interpreter aliases.sh file_simple.sh
CASES

@test "invoking resholve with a non-executable interpreter prints an error" {
  require <({
    status 1
    line -1 equals "AssertionError: Interpreter must be executable"
  })
  # just using a random non-executable script as interp
} <<'CASES'
resholve --interpreter $PWD/aliases.sh < file_simple.sh
resholve --interpreter $PWD/aliases.sh file_simple.sh
CASES


@test "invoking resholve without script's deps prints an error" {
  RESHOLVE_PATH=''
  require <({
    status 3
    line -1 contains "Can't resolve command 'file' to a known function or executable"
  })
} <<CASES
resholve --interpreter $INTERP < file_simple.sh
resholve --interpreter $INTERP file_simple.sh
CASES

@test "resholve resolves simple external dependency from command-line args" {
  require <({
    status 0
    line -1 contains "wrote "
  })
} <<CASES
resholve --interpreter $INTERP file_simple.sh
resholve --interpreter $INTERP file_simple.sh source_present_target.sh
CASES

@test "resholve resolves simple external dependency from stdin" {

  require <({
    status 0
    line -1 begins "# resholve: keep /nix/store"
    line -1 contains "-file-"
    line -1 ends "/bin/file"
  })
} <<CASES
resholve --interpreter $INTERP < file_simple.sh
CASES

export FILE_PATH="$RESHOLVE_PATH"
@test "path/inputs can be supplied with the inputs alias" {
  unset RESHOLVE_PATH
  export RESHOLVE_INPUTS=
  declare -p FILE_PATH
  require <({
    status 0
    line -1 contains "wrote "
  })
} <<CASES
RESHOLVE_INPUTS="$FILE_PATH" resholve --interpreter $INTERP file_simple.sh
resholve --inputs "$FILE_PATH" --interpreter $INTERP file_simple.sh
CASES

@test "only one of path/inputs can be supplied" {
  require <({
    status 2
    line -1 equals "resholve: error: argument --inputs: not allowed with argument --path"
  })
} <<CASES
RESHOLVE_INPUTS="$RESHOLVE_PATH" resholve --interpreter $INTERP < file_simple.sh
resholve --inputs "$RESHOLVE_PATH" --interpreter $INTERP file_simple.sh
CASES

@test "resholve fails if target script isn't found" {
  require <({
    status 2
    line -1 begins "Aborting due to missing file: '/hopenot/file_simple.sh'"
  })
} <<CASES
resholve --interpreter $INTERP /hopenot/file_simple.sh
resholve --interpreter $INTERP file_simple.sh /hopenot/file_simple.sh
CASES

@test "resholve fails with duplicate input scripts" {

  require <({
    status 2
    line 1 equals "Aborting due to duplicate script targets."
  })
} <<CASES
resholve --interpreter $INTERP file_simple.sh source_present_target.sh source_present_target.sh
CASES

@test "resholve fails when scripts have untriaged dynamic elements" {

  require <({
    status 6
    line -1 contains "Can't resolve 'source' with a dynamic argument"
  })
} <<CASES
resholve --interpreter $INTERP source_var_pwd.sh
resholve --interpreter $INTERP source_home_pwd.sh
CASES

@test "resholve fails when 'keep' directives are misformatted" {

  require <({
    status 2
    line -1 ends "valid single-part keep directives: \$variable, absolute path, ~/path"
  })
} <<CASES
resholve --interpreter $INTERP --keep source PWD source_var_pwd.sh
resholve --interpreter $INTERP --keep PWD source_var_pwd.sh
resholve --interpreter $INTERP < source_var_pwd_bad_annotation.sh
CASES

@test "resholve fails when triage directive doesn't specify the right thing" {
  require <({
    status 6
    line -1 contains "Can't resolve 'source' with a dynamic argument"
  })
} <<CASES
resholve --interpreter $INTERP --keep command:\$PWD < source_var_pwd.sh
RESHOLVE_KEEP='command:\$PWD' resholve --interpreter $INTERP < source_var_pwd.sh
resholve --interpreter $INTERP --keep source:\$HOME < source_var_pwd.sh
RESHOLVE_KEEP='source:\$HOME' resholve --interpreter $INTERP < source_var_pwd.sh
resholve --interpreter $INTERP < source_var_pwd_misannotated.sh
resholve --interpreter $INTERP --keep source:\$PWD < source_home_pwd.sh
RESHOLVE_KEEP='source:\$PWD' resholve --interpreter $INTERP < source_home_pwd.sh
CASES

@test "resholve succeeds when 1x 'keep' directives are correct" {

  require <({
    status 0
    line -2 begins "### resholve directives (auto-generated)"
    line -1 equals "# resholve: keep source:\$PWD"
  })
} <<CASES
resholve --interpreter $INTERP --keep 'source:\$PWD' < source_var_pwd.sh
RESHOLVE_KEEP='source:\$PWD' resholve --interpreter $INTERP < source_var_pwd.sh
resholve --interpreter $INTERP < source_var_pwd_annotated.sh
CASES

@test "resholve succeeds when 2x 'keep' directives are correct" {

  require <({
    status 0
    line -3 begins "### resholve directives (auto-generated)"
    # Note: the output order of these in-doc directives is sorted;
    # it *should* be idempotent for equivalent inputs!
    line -2 equals "# resholve: keep source:\$HOME"
    line -1 equals "# resholve: keep source:\$PWD"
  })
} <<CASES
resholve --interpreter $INTERP --keep 'source:\$PWD' --keep 'source:\$HOME' < source_home_pwd.sh
RESHOLVE_KEEP='source:\$PWD source:\$HOME' resholve --interpreter $INTERP < source_home_pwd.sh
resholve --interpreter $INTERP --keep 'source:\$PWD source:\$HOME' < source_home_pwd.sh
RESHOLVE_KEEP='source:\$PWD' resholve --interpreter $INTERP < source_home_pwd_annotated_incomplete.sh
resholve --interpreter $INTERP --keep 'source:\$PWD' < source_home_pwd_annotated_incomplete.sh
CASES
# Note (Dec 12 2020): In case I reverse course on merging env directives:
# The 3rd case previously confirmed that envvars were merged with flags and
# in-doc directives. I moved 'source:\$HOME' from RESHOLVE_KEEP into --keep

@test "Don't resolve aliases without '--fix aliases'" {
  require <({
    status 0
    line 4 !contains "/nix/store"
    line 5 !contains 'find="/nix/store'
    line 5 !contains 'find2="/nix/store'
    line 7 !contains "/nix/store"
    line 9 !contains "/nix/store"
    line 10 contains "/nix/store"
    line 11 !contains "/nix/store"
    line 12 contains "/nix/store"
    line 13 begins "### resholve directives (auto-generated)"
    # can't assert the ends; these get sorted
    # and the hash makes unstable :(
    line 14 begins "# resholve: keep /nix/store/"
    line 15 begins "# resholve: keep /nix/store/"
  })
} <<CASES
resholve --interpreter $INTERP < alias_riddle.sh
CASES

@test "Inject before and after script" {
  require <({
    status 0
    line 6 equals "# begin prologue inserted by resholve"
    line -1 equals '# end epilogue inserted by resholve'
  })
} <<CASES
resholve --interpreter $INTERP --prologue <(echo "declare BEFORE") --epilogue <(echo "declare AFTER") < find_beginning_and_end.sh
resholve --interpreter $INTERP --prologue <(echo "declare BEFORE")  --epilogue <(echo "declare AFTER") < find_beginning_and_end2.sh
CASES
