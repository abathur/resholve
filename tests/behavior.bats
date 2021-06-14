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
    line 7 contains "eval_quoted.sh:7: $quoted_eval"
    line 11 contains "eval_quoted.sh:12: $quoted_eval"
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
    line 3 contains "error: Unexpected " # full errors noted below
    # paren error: "Unexpected word while parsing command line"
    # brace error: "Unexpected right brace"
  })
} <<CASES
resholve --interpreter $INTERP < coproc_named_brace.sh
resholve --interpreter $INTERP < coproc_named_paren.sh
CASES

@test "objects to unexempted absolute source paths" {
  require <({
    status 5
    line 3 ends "Unexpected absolute source path (not supplied by a listed dependency)."
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
    line 3 ends "Unexpected absolute source path (not supplied by a listed dependency)."
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
    status 7
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


fs=$':'

@test "resolve fails without lore" {
  require <({
    status 8
    line -1 contains "I don't have any lore for '/nix/store/"
  })
} <<CASES
RESHOLVE_LORE=$EMPTY_LORE resholve --interpreter $INTERP < nested_execer.sh
CASES


@test "resolve fails without assay" {
  require <({
    status 9
    line -1 contains "'cat' _might_ be able to execute its arguments, and I don't have any command-specific rules for figuring out if this specific invocation does or not."
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" < assay.sh
CASES

@test "resolve fails with bad assay" {
  require <({
    status 9
    line -1 contains "'cat' _might_ be able to execute its arguments, and I don't have any command-specific rules for figuring out if this specific invocation does or not."
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p head)${fs}head${fs}yes${fs}4) < assay.sh
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat${fs}yes${fs}4) < assay.sh
CASES

@test "resolve fails with overshooting assay wordnum" {
  require <({
    status 10
    line 3 contains "I have an assay matching this invocation, but: the wordnum index"
    line 3 contains "is too large to zero-index args(4)"
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}4) < assay.sh
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}5) < assay.sh
CASES

@test "resolve fails with assay wordnum 0" {
  require <({
    status 1 # TODO: should be 2
    line -1 contains "assay wordnum should be 1+ (0 is the same as the invoking command itself)"
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}0) < assay.sh
CASES

@test "resolve fails with undershooting assay wordnum" {
  require <({
    status 3
    line 3 contains "Couldn't resolve command"
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}1) < assay.sh
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}2) < assay.sh
CASES

@test "resolve succeeds with assay" {
  require <({
    status 0
    line -1 contains "bin/head"
  })
} <<CASES
unset RESHOLVE_LORE && RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP --execer "can${fs}$(type -p cat)" --execer "cannot${fs}$(type -p head)" --assay <(echo $(type -p cat)${fs}cat CANNOT="do this" --not-a-real-flag head${fs}yes${fs}3) < assay.sh
CASES

@test "resolve commands mixed with varlike assignments" {
  require <({
    status 0
    line 2 begins 'HOME=oops LC_ALL=c /nix/store/'
    line 2 ends '/bin/file heh'
    line 3 begins 'find=find /nix/store/'
    line 3 contains '/bin/env LC_ALL=c HOME=yeah /nix/store/'
    line 3 contains '/bin/find /nix/store -name find -exec /nix/store/'
    line 3 ends '/bin/file {} + -executable'
  })
} <<CASES
RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP < varlike_in_invocation.sh
CASES

builtin_overridden="FEEDBACK WANTED: Essential builtin overridden by"
@test "verify warnings are thrown for overridden builtins" {
  require <({
    status 0
    line 3 contains "builtin_overridden.sh:6: $builtin_overridden alias"
    line 7 contains "builtin_overridden.sh:7: $builtin_overridden function"
  })
} <<CASES
resholve --interpreter $INTERP builtin_overridden.sh
CASES

bad_word_eval="FEEDBACK WANTED: OSH eval error while looking for sub-exec in"
@test "verify warnings are thrown for OSH eval errors" {
  require <({
    status 0
    # 4 first because essential builtins
    # get handled ~immediately
    line 3 contains "bad_word_eval.sh:4: $bad_word_eval essential builtin 'eval'"
    line 7 contains "bad_word_eval.sh:2: $bad_word_eval general builtin 'exec'"
    line 11 contains "bad_word_eval.sh:3: $bad_word_eval external 'env'"
  })
} <<CASES
RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_COREUTILS" resholve --interpreter $INTERP bad_word_eval.sh
CASES

@test "Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo" {
  require <({
    status 0
    line 2 contains '/bin/find . -name buffalo -exec /nix/store/'
  })
} <<CASES
RESHOLVE_PATH="$RESHOLVE_PATH:$PKG_FINDUTILS" resholve --interpreter $INTERP < buffalo.sh
CASES
