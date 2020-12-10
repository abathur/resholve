# Unsure about the name of this suite, but the intent is to collect tests
# that try to stake out/exercise specific behavior that demonstrate and
# codify where the boundaries of what resholve knows how to handle are.

load helpers

# TODO: replace w/ real test once issue is sorted
quoted_eval="FEEDBACK WANTED: Letting quoted 'eval' through"
@test "verify warnings are thrown for quoted evals" {
  require <({
    status 0
    line 3 contains "eval_quoted.sh:3: $quoted_eval"
    line 6 contains "eval_quoted.sh:6: $quoted_eval"
    line 9 contains "eval_quoted.sh:11: $quoted_eval"
  })
} <<CASES
resholve --interpreter $INTERP eval_quoted.sh
CASES

@test "verify --keep '$varname' allows dynamic commands (first-word variable)" {
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
