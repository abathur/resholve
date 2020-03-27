import pytest


def gen(script, args="", env=None, expect=None):
    return (script, args, env, expect)


ISSUE = "problems"
OK = "clean"


@pytest.mark.parametrize(
    ("script", "argstr", "env", "expect"),
    [
        gen("command_in_function.sh", expect=ISSUE),
        gen("absolute_path.sh", expect=ISSUE),
        gen("source_var_pwd.sh", expect=ISSUE),
        gen("file_in_function.sh", expect=OK),
        gen("file_home_source_pwd.sh", expect=ISSUE),
        gen("file_home_source_pwd.sh", args="--allow source:PWD", expect=OK),
        gen("file_home_source_pwd.sh", env={"RESHOLVE_ALLOW": "source:PWD"}, expect=OK),
        gen("which_simple.sh", expect=ISSUE),
        gen("source_missing_target.sh", expect=ISSUE),
        gen("file_simple.sh", expect=OK),
        gen("source_present_target.sh", expect=OK),
    ],
)
def test_demo(demo, script, argstr, env, expect):
    stdout, status = demo(script, argstr, env)
    if expect == ISSUE:
        assert status > 2
    elif expect == OK:
        assert status == 0, "\n".join(stdout)
    else:
        assert status != 2, "syntax error?"
        raise Exception("ruh roh")
