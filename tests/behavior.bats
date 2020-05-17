# Unsure about the name of this suite, but the intent is to collect tests
# that try to stake out/exercise specific behavior that demonstrate and
# codify where the boundaries of what resholved knows how to handle are.

load helpers

# TODO: replace w/ real test once issue is sorted
quoted_eval="FEEDBACK WANTED: Letting quoted 'eval' through"
@test "verify warnings are thrown for quoted evals" {
  require <({
    status 0
    line 2 contains "eval_quoted.sh:3: $quoted_eval"
    line 5 contains "eval_quoted.sh:6: $quoted_eval"
    line 8 contains "eval_quoted.sh:11: $quoted_eval"
  })
} <<CASES
resholver eval_quoted.sh
CASES

# TODO: replace w/ real test once issue is sorted
var_as_command="FEEDBACK WANTED: Letting dynamic command (first-word variable) through"
@test "verify warnings are thrown for variable-as-command" {
  require <({
    status 0
    line 2 contains "variable_as_command.sh:7: $var_as_command"
    line 5 contains "variable_as_command.sh:8: $var_as_command"
    line 8 contains "variable_as_command.sh:9: $var_as_command"
    line 11 contains "variable_as_command.sh:10: $var_as_command"
    line 14 contains "variable_as_command.sh:11: $var_as_command"

    line 17 contains "variable_as_command.sh:17: $var_as_command"
    line 20 contains "variable_as_command.sh:18: $var_as_command"
    line 23 contains "variable_as_command.sh:19: $var_as_command"

    line 26 contains "variable_as_command.sh:23: $var_as_command"
    line 29 contains "variable_as_command.sh:24: $var_as_command"
    line 32 contains "variable_as_command.sh:25: $var_as_command"
    line 35 contains "variable_as_command.sh:26: $var_as_command"
    line 38 contains "variable_as_command.sh:27: $var_as_command"

    line 41 contains "variable_as_command.sh:33: $var_as_command"
    line 44 contains "variable_as_command.sh:34: $var_as_command"
    line 47 contains "variable_as_command.sh:35: $var_as_command"
    line 50 contains "variable_as_command.sh:36: $var_as_command"
    line 53 contains "variable_as_command.sh:37: $var_as_command"

    line 56 contains "variable_as_command.sh:43: $var_as_command"
    line 59 contains "variable_as_command.sh:44: $var_as_command"
    line 62 contains "variable_as_command.sh:45: $var_as_command"

    line 65 contains "variable_as_command.sh:49: $var_as_command"
    line 68 contains "variable_as_command.sh:50: $var_as_command"
    line 71 contains "variable_as_command.sh:51: $var_as_command"

    line 74 contains "variable_as_command.sh:69: $var_as_command"
    line 77 contains "variable_as_command.sh:70: $var_as_command"
    line 80 contains "variable_as_command.sh:71: $var_as_command"
    line 83 contains "variable_as_command.sh:72: $var_as_command"

  })
} <<CASES
resholver variable_as_command.sh
CASES
