import pytest
import os


@pytest.mark.parametrize(
    "command", ["resholver < file_simple.sh", "resholver file_simple.sh"]
)
def test_err_without_dep_path(shell, command):
    out, status = shell(command)

    assert status == 1, "status 1 if no dependency path"

    assert out[-1] == "AssertionError: RESHOLVE_PATH must be set"


@pytest.mark.parametrize(
    "command",
    [
        "RESHOLVE_PATH='' resholver < file_simple.sh",
        "RESHOLVE_PATH='' resholver file_simple.sh",
    ],
)
def test_fail_without_dep_in_dep_path(shell, command):
    out, status = shell(command)

    assert status == 3, "status 3 without command in dep path"

    assert "Can't resolve command 'file' to a known function or executable" in out[-1]


try:
    deps = os.environ["RESHOLVE_PATH"]
except KeyError:
    raise Exception(
        "Test environment should have RESHOLVE_PATH containing, at minimum, the 'file' command."
    )

dep_path = "RESHOLVE_PATH={:}".format(deps)


def with_deps(command):
    form = "{:} {:}"
    desc = form.format("RESHOLVE_PATH=<...>", command)
    return pytest.param(form.format(dep_path, command), id=desc)


@pytest.mark.parametrize(
    "command",
    [
        # pytest.param(1, 3, marks=pytest.mark.bar)
        with_deps("resholver < file_simple.sh")
    ],
)
def test_ok_with_dep_in_dep_path_stdout(shell, command):
    out, status = shell(command)
    assert status == 0

    assert "/nix/store/" in out[-1]
    assert "-file-" in out[-1]
    assert "/bin/file" in out[-1]


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver file_simple.sh"),
        with_deps("resholver file_simple.sh source_present_target.sh"),
    ],
)
def test_ok_with_dep_in_dep_path_file(shell, command):
    out, status = shell(command)
    assert status == 0
    assert out[-1].startswith("Rewrote ")
    assert out[-1].endswith(".resolved'")

    out, status = shell("cat file_simple.sh.resolved")
    assert status == 0
    assert "/nix/store/" in out[-1]
    assert "-file-" in out[-1]
    assert "/bin/file" in out[-1]


@pytest.mark.parametrize(
    "command",
    [
        # pytest.param(1, 3, marks=pytest.mark.bar)
        with_deps("resholver /hopenot/file_simple.sh"),
        with_deps("resholver file_simple.sh /hopenot/file_simple.sh"),
    ],
)
def test_fail_with_bad_script(shell, command):
    out, status = shell(command)

    assert status == 2
    assert out[-1] == "Aborting due to missing file: '/hopenot/file_simple.sh'"


@pytest.mark.parametrize(
    "command",
    [
        with_deps(
            "resholver file_simple.sh source_present_target.sh source_present_target.sh"
        )
    ],
)
def test_fail_with_duplicate_scripts(shell, command):
    out, status = shell(command)
    assert status == 2
    assert out[0] == "Aborting due to duplicate script targets."


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver source_var_pwd.sh"),
        with_deps("resholver source_home_pwd.sh"),
    ],
)
def test_allow_missing(shell, command):
    out, status = shell(command)
    assert status == 6
    assert (
        "Can't resolve 'source' with an argument that can't be statically parsed"
        in out[-1]
    )


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver --allow source PWD source_var_pwd.sh"),
        with_deps("resholver --allow PWD source_var_pwd.sh"),
        with_deps("resholver < source_var_pwd_bad_annotation.sh"),
    ],
)
def test_allow_misformat(shell, command):
    out, status = shell(command)

    assert status == 2
    assert "should be a scope:var pair" in out[-1]


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver --allow command:PWD < source_var_pwd.sh"),
        with_deps("RESHOLVE_ALLOW='command:PWD' resholver < source_var_pwd.sh"),
        with_deps("resholver --allow source:HOME < source_var_pwd.sh"),
        with_deps("RESHOLVE_ALLOW='source:HOME' resholver < source_var_pwd.sh"),
        with_deps("resholver < source_var_pwd_misannotated.sh"),
    ],
)
def test_allow_single_wrong(shell, command):
    out, status = shell(command)
    assert status == 6
    assert (
        "Can't resolve 'source' with an argument that can't be statically parsed"
        in out[-1]
    )


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver --allow source:PWD < source_var_pwd.sh"),
        with_deps("RESHOLVE_ALLOW='source:PWD' resholver < source_var_pwd.sh"),
        with_deps("resholver < source_var_pwd_annotated.sh"),
    ],
)
def test_allow_single(shell, command):
    out, status = shell(command)
    assert status == 0
    assert out[-2] == "### resholved directives (auto-generated)"
    assert out[-1] == "# resholved: allow source:PWD"


@pytest.mark.parametrize(
    "command",
    [
        with_deps("resholver --allow source:PWD < source_home_pwd.sh"),
        with_deps("RESHOLVE_ALLOW='source:PWD' resholver < source_home_pwd.sh"),
    ],
)
def test_allow_double_missing_1(shell, command):
    out, status = shell(command)
    assert status == 6
    assert (
        "Can't resolve 'source' with an argument that can't be statically parsed"
        in out[-1]
    )


@pytest.mark.parametrize(
    "command",
    [
        with_deps(
            "resholver --allow source:PWD --allow source:HOME < source_home_pwd.sh"
        ),
        with_deps(
            "RESHOLVE_ALLOW='source:PWD source:HOME' resholver < source_home_pwd.sh"
        ),
        with_deps(
            "RESHOLVE_ALLOW='source:PWD' resholver --allow source:HOME < source_home_pwd.sh"
        ),
        with_deps(
            "RESHOLVE_ALLOW='source:PWD' resholver < source_home_pwd_annotated_incomplete.sh"
        ),
        with_deps(
            "resholver --allow source:PWD < source_home_pwd_annotated_incomplete.sh"
        ),
    ],
)
def test_allow_double(shell, command):
    out, status = shell(command)
    print(out, status)
    assert status == 0
    assert out[-3] == "### resholved directives (auto-generated)"
    # Note: the output order of these in-doc directives is sorted; it *should* be idempotent for equivalent inputs!
    assert out[-2] == "# resholved: allow source:HOME"
    assert out[-1] == "# resholved: allow source:PWD"
