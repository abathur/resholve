import os
import textwrap
import difflib

import pytest


def rule(character, color, label=""):
    return "\033[{:}m".format(color) + label.center(60, character) + "\033[0m"


@pytest.fixture(scope="session")
def bash():
    from pytest_shell.shell import LocalBashSession

    yield LocalBashSession


@pytest.fixture
def demo(bash, record_property):
    def reporting_shell(script, argstr="", env=None):
        with bash(envvars=env or dict(), cmd="bash", pwd="demo") as s:
            s.auto_return_code_error = False
            record_property(
                "original", (s.send("cat " + script) + "\n").splitlines(True)
            )
            command = "resholver{:} < {:}".format(
                " " + argstr if len(argstr) else argstr, script
            )
            output = s.send(command)
            code = s.last_return_code
            # TODO: use a loop
            record_property("script", script)
            record_property("env", env)
            record_property("argstr", argstr)
            record_property("status", code)
            record_property("output", (output + "\n").splitlines(True))
            record_property("command", command)

            return output.splitlines(), code

    yield reporting_shell


original_fmt = """
Original:
{original:}
"""
output_fmt = """
Output:
{output:}
"""
diff_fmt = """
Diff:
{diff:}
"""
report_fmt = """
{headline:}
{header:}Command: {command:}
{body:}{tailline:}
"""


INDENT = "\033[{:}m>>>\033[0m ".format(34)


def indent(strlist):
    return INDENT + INDENT.join(strlist)


COLOR_LINE = "\033[{:}m{:}\033[0m"


def color_diff(lines):
    for line in lines:
        if line.startswith("+"):
            yield COLOR_LINE.format(32, line)
        elif line.startswith("-"):
            yield COLOR_LINE.format(31, line)
        elif line.startswith("@"):
            yield COLOR_LINE.format(36, line)
        else:
            yield line


def summarize(status, output, original, script, command, argstr, env):
    code = 35 if status else 36
    if status:
        header = original_fmt.format(original=indent(original))
        body = output_fmt.format(output=indent(output))
    else:
        header = ""
        body = diff_fmt.format(
            diff=indent(
                color_diff(
                    difflib.unified_diff(
                        original, output, "original", "resolved", n=100
                    )
                )
            )
        )
    return report_fmt.format(
        headline=rule(
            "-",
            code,
            "{:} {:} (status: {:})".format(
                script, "unresolved" if status else "resolved", status
            ),
        ),
        header=header,
        command=command,
        body=body,
        tailline=rule("^", code),
    )
    out = "\n{:}\n{:}\n{:}".format(rule("-", code, script), output, rule("^", code))
    return out


def pytest_report_teststatus(report, config):
    try:
        if report.when == "call":
            extra = dict(report.user_properties)
            details = summarize(**extra)
            return (report.outcome, details, details)
    except Exception as e:
        return (report.outcome, e, "TEST")


def pytest_report_header(config):
    return "RESHOLVE_PATH: " + os.environ["RESHOLVE_PATH"]
