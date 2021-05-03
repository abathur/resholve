# Unsure about the name of this suite, but the intent is to collect tests
# that try to stake out/exercise specific behavior that demonstrate and
# codify where the boundaries of what resholve knows how to handle are.

load helpers

# TODO: replace w/ real test once issue is sorted
quoted_eval="FEEDBACK WANTED: Letting quoted 'eval' through"
@test "verify warnings are thrown for quoted evals" {
  require <({
    status 0
    line 3 contains "eval_quoted.sh:4: $quoted_eval"
    line 6 contains "eval_quoted.sh:7: $quoted_eval"
    line 9 contains "eval_quoted.sh:12: $quoted_eval"
  })
} <<CASES
resholve --interpreter $INTERP eval_quoted.sh
CASES

@test "verify --keep '$varname' allows dynamic commands" {
  require <({
    status 0
    line -1 begins "Rewrote"
    line -1 ends "variable_as_command.sh.resolved'"
  })
} <<CASES
resholve --interpreter $INTERP --keep '\$GIT_PROGRAM \$LS_PROGRAM \$STAT_HERE \$STAT_ELSEWHERE' variable_as_command.sh
CASES

@test "Resolve aliases when specified" {
  require <({
    status 0
    line 4 !contains "/nix/store"
    line 5 contains 'find="/nix/store'
    line 5 contains 'find2="/nix/store'
    line 7 !contains "/nix/store"
    line 9 !contains "/nix/store"
    line 10 contains "/nix/store"
    line 11 !contains "/nix/store"
    line 12 contains "/nix/store"
    line 13 begins "### resholve directives (auto-generated)"
    # can't assert the ends; these get sorted
    # and the hash makes unstable :(
    line 14 equals "# resholve: fix aliases"
    line 15 begins "# resholve: keep /nix/store/"
    line 16 begins "# resholve: keep /nix/store/"
  })
} <<CASES
resholve --interpreter $INTERP --fix aliases < alias_riddle.sh
RESHOLVE_FIX=aliases resholve --interpreter $INTERP < alias_riddle.sh
CASES

@test "can resolve a simple coproc" {
  require <({
    status 0
    line 2 begins "coproc /nix/store"
    line 2 ends "bin/file"
  })
} <<CASES
resholve --interpreter $INTERP < coproc_simple.sh
CASES

@test "can't resolve a named coproc w/o upstream support :(" {
  require <({
    status 1
    line 3 ends "error: Unexpected word while parsing command line"
  })
} <<CASES
resholve --interpreter $INTERP < coproc_named.sh
CASES

@test "objects to unexempted absolute source paths" {
  require <({
    status 5
    line 3 ends "Unexpected absolute source path (not supplied by a listed dependency). You should patch/substitute it."
  })
} <<CASES
resholve --interpreter $INTERP < absolute_source.sh
CASES

echo "source $PWD/tests/source_present_target.sh" > $PWD/tests/temp_source_test.sh
@test "allows exempted absolute source paths" {
  require <({
    status 0
    line -1 ends "/tests/source_present_target.sh"
  })
} <<CASES
resholve --interpreter $INTERP --keep source:$PWD/tests/source_present_target.sh < $PWD/tests/temp_source_test.sh && rm $PWD/tests/temp_source_test.sh
CASES

@test "allow (but do not parse) --fake 'source:path'" {
  require <({
    status 5
    line 3 ends "Unexpected absolute source path (not supplied by a listed dependency). You should patch/substitute it."
  })
} <<CASES
resholve --interpreter $INTERP --fake 'source:/not/a/real/script' < absolute_source.sh
CASES

@test "allow (*and* do not parse) --keep 'source:path' + --fake 'source:path'" {
  require <({
    status 0
    line 2 equals "source /not/a/real/script"
  })
} <<CASES
resholve --interpreter $INTERP --keep 'source:/not/a/real/script' --fake 'source:/not/a/real/script' < absolute_source.sh
resholve --interpreter $INTERP --keep '.:/not/a/real/script' --fake 'source:/not/a/real/script' < absolute_source.sh
CASES

@test "objects to unexempted tilde executable paths" {
  require <({
    status 9
    line -1 equals "[ stdinNone ]:2: Can't resolve dynamic command"
  })
} <<CASES
resholve --interpreter $INTERP < $PWD/tests/tilde_dynamic_pipeline.sh
CASES

@test "allows exempted tilde executable paths" {
  require <({
    status 0
    line -1 equals "# resholve: keep ~/.bashrc"
  })
} <<CASES
resholve --interpreter $INTERP --keep '~/.bashrc' < $PWD/tests/tilde_dynamic_pipeline.sh
CASES

@test "allows --fake executable" {
  require <({
    status 0
    line -1 equals "# resholve: fake external:osascript"
  })
} <<CASES
resholve --interpreter $INTERP --fake 'external:osascript' < osascript.sh
CASES

@test "allows --fake function with colons" {
  require <({
    status 0
    line -2 equals "# resholve: fake function:colon:colon:colon"
    line -1 equals "# resholve: fake function:weirdtimes"
  })
} <<CASES
resholve --interpreter $INTERP --fake 'function:colon:colon:colon;weirdtimes' < function_colon.sh
CASES

@test "resolve abspath with --fix abspath" {
  require <({
    status 0
    line 2 begins "/nix/store/"
    line 2 ends "/bin/file"
  })
} <<CASES
resholve --interpreter $INTERP --fix '/usr/bin/file' < abspath_command.sh
CASES

us=$'\x1f'
@test "resolve commands in args to execing executables" {
  require <({
    status 0
    line 5 contains '/bin/find $(type -p file) -name file -exec /nix/store/'
    line 5 contains "/bin/file {} +  "
  })
} <<CASES
resholve --interpreter $INTERP --assay <(echo $(type -p find)${us}find __NO_COMMAND_SUB__ -name file -exec file {} +${us}yes${us}5 ; echo abspath${us}cmdname${us}args${us}no) < nested_execer.sh
CASES
