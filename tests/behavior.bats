load helpers

@test "verify warnings are thrown for quoted evals" {
  require <({
    status 0
    line 2 contains "eval_quoted.sh:3: FEEDBACK WANTED:"
    line 5 contains "eval_quoted.sh:6: FEEDBACK WANTED:"
    line 8 contains "eval_quoted.sh:11: FEEDBACK WANTED:"
  })
} <<CASES
resholver eval_quoted.sh
CASES
