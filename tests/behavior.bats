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

# TODO: replace w/ real test once issue is sorted
var_as_command="FEEDBACK WANTED: Letting dynamic command (first-word variable) through"
@test "verify warnings are thrown for variable-as-command" {
  require <({
    status 0
    line 3 contains "variable_as_command.sh:7: $var_as_command"
    line 6 contains "variable_as_command.sh:8: $var_as_command"
    line 9 contains "variable_as_command.sh:9: $var_as_command"
    line 12 contains "variable_as_command.sh:10: $var_as_command"
    line 15 contains "variable_as_command.sh:11: $var_as_command"

    line 18 contains "variable_as_command.sh:17: $var_as_command"
    line 21 contains "variable_as_command.sh:18: $var_as_command"
    line 24 contains "variable_as_command.sh:19: $var_as_command"

    line 27 contains "variable_as_command.sh:23: $var_as_command"
    line 30 contains "variable_as_command.sh:24: $var_as_command"
    line 33 contains "variable_as_command.sh:25: $var_as_command"
    line 36 contains "variable_as_command.sh:26: $var_as_command"
    line 39 contains "variable_as_command.sh:27: $var_as_command"

    line 42 contains "variable_as_command.sh:33: $var_as_command"
    line 45 contains "variable_as_command.sh:34: $var_as_command"
    line 48 contains "variable_as_command.sh:35: $var_as_command"
    line 51 contains "variable_as_command.sh:36: $var_as_command"
    line 54 contains "variable_as_command.sh:37: $var_as_command"

    line 57 contains "variable_as_command.sh:43: $var_as_command"
    line 60 contains "variable_as_command.sh:44: $var_as_command"
    line 63 contains "variable_as_command.sh:45: $var_as_command"

    line 66 contains "variable_as_command.sh:49: $var_as_command"
    line 69 contains "variable_as_command.sh:50: $var_as_command"
    line 72 contains "variable_as_command.sh:51: $var_as_command"

    line 75 contains "variable_as_command.sh:69: $var_as_command"
    line 78 contains "variable_as_command.sh:70: $var_as_command"
    line 81 contains "variable_as_command.sh:71: $var_as_command"
    line 84 contains "variable_as_command.sh:72: $var_as_command"

  })
} <<CASES
resholve --interpreter $INTERP variable_as_command.sh
CASES
