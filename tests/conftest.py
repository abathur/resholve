import pytest
import os
from distutils.spawn import find_executable

# TODO: I had to fiddle with letting through just a little of the environment
# I'm leaving everything intact here for now so that it's simple to relitigate
# but it's probably fine to dump these after May 1, 2020
DEFAULT_KEEP = {
    # "__CF_USER_TEXT_ENCODING",
    # "__darwinAllowLocalNetworking",
    # "__impureHostDeps",
    # "__NIX_DARWIN_SET_ENVIRONMENT_DONE",
    # "__propagatedImpureHostDeps",
    # "__propagatedSandboxProfile",
    # "__sandboxProfile",
    # "Apple_PubSub_Socket_Render",
    # "AR",
    # "AS",
    # "builder",
    # "buildInputs",
    # "CC",
    # "CMAKE_OSX_ARCHITECTURES",
    # "CONFIG_SHELL",
    # "configureFlags",
    # "CXX",
    # "depsBuildBuild",
    # "depsBuildBuildPropagated",
    # "depsBuildTarget",
    # "depsBuildTargetPropagated",
    # "depsHostHost",
    # "depsHostHostPropagated",
    # "depsTargetTarget",
    # "depsTargetTargetPropagated",
    # "DETERMINISTIC_BUILD",
    # "doCheck",
    # "doInstallCheck",
    # "EDITOR",
    # "GETTEXTDATADIRS",
    # "gl_cv_func_getcwd_abort_bug",
    # "HAG_PIPE",
    # "HAG_PURPOSE",
    # "HAG_PURPOSE_DIR",
    # "HAG_PURPOSE_INIT_FILE",
    # "HAG_PURPOSE_PWD_FILE",
    # "HAG_SESSION_DIR",
    # "HAG_SHOULD_NOT_RECORD_HISTORY",
    # "HISTCONTROL",
    # "HISTFILE",
    # "HISTIGNORE",
    # "HISTTIMEFORMAT",
    # "HOME",
    # "HOST_PATH",
    # "IN_NIX_SHELL",
    # "LANG",
    # "LD",
    # "LD_DYLD_PATH",
    # "LOGNAME",
    # "MACOSX_DEPLOYMENT_TARGET",
    # "name",
    # "nativeBuildInputs",
    # "NICKLES",
    # "NIX_BINTOOLS",
    # "NIX_BINTOOLS_WRAPPER_x86_64_apple_darwin_TARGET_HOST",
    # "NIX_BUILD_CORES",
    # "NIX_BUILD_DONT_SET_RPATH",
    # "NIX_BUILD_TOP",
    # "NIX_CC",
    # "NIX_CC_WRAPPER_x86_64_apple_darwin_TARGET_HOST",
    # "NIX_CFLAGS_COMPILE",
    # "NIX_COREFOUNDATION_RPATH",
    # "NIX_CURRENT_LOAD",
    # "NIX_CXXSTDLIB_COMPILE",
    # "NIX_CXXSTDLIB_LINK",
    # "NIX_DONT_SET_RPATH",
    # "NIX_ENFORCE_NO_NATIVE",
    # "NIX_HARDENING_ENABLE",
    # "NIX_IGNORE_LD_THROUGH_GCC",
    # "NIX_INDENT_MAKE",
    # "NIX_LDFLAGS",
    # "NIX_NO_SELF_RPATH",
    # "NIX_PATH",
    # "NIX_SSL_CERT_FILE",
    # "NIX_STORE",
    # "NM",
    # "nobuildPhase",
    # "OLDPWD",
    # "out",
    # "outputs",
    # "PAGER",
    # "patches",
    "PATH",
    # "PATH_LOCALE",
    # "phases",
    # "PICKLES",
    # "PROMPT_COMMAND",
    # "propagatedBuildInputs",
    # "propagatedNativeBuildInputs",
    # "PWD",
    "PYTHONHASHSEED",
    "PYTHONNOUSERSITE",
    "PYTHONPATH",
    # "RANLIB",
    # "SDKROOT",
    # "SECURITYSESSIONID",
    # "SHELL",
    # "shell",
    # "RESHOLVE_PATH",
    # "shellHook",
    # "SHLVL",
    # "SIZE",
    # "SOURCE_DATE_EPOCH",
    # "SSH_AUTH_SOCK",
    # "stdenv",
    # "strictDeps",
    # "STRINGS",
    # "STRIP",
    # "system",
    "TEMP",
    "TEMPDIR",
    # "TERM",
    # "TERM_PROGRAM",
    # "TERM_PROGRAM_VERSION",
    # "TERM_SESSION_ID",
    "TMP",
    "TMPDIR",
    # "USER",
    # "VISUAL",
    # "XPC_FLAGS",
    # "XPC_SERVICE_NAME",
}

_our_bash = find_executable("bash")
_our_env = find_executable("env")
_base_env = {key: os.environ[key] for key in DEFAULT_KEEP}
_our_bash_command = (
    _our_env,
    "-i",
    " ".join(("{:}={:}".format(k, v) for k, v in _base_env.items())),
    _our_bash,
)


def pytest_report_header(config):
    return "RESHOLVE_PATH: " + os.environ["RESHOLVE_PATH"]


@pytest.fixture(scope="session")
def bash():
    from pytest_shell.shell import LocalBashSession

    yield LocalBashSession


@pytest.fixture
def shell(bash):
    def reporting_shell(command, env=None):
        if env:
            env.update(_base_env)
        else:
            env = _base_env

        with bash(envvars=env, cmd=_our_bash_command, pwd="tests") as s:
            s.auto_return_code_error = False
            return s.send(command).splitlines(), s.last_return_code

    yield reporting_shell


@pytest.fixture
def resholver(shell):  # shell?
    def reporting_shell(script, argstr="", env=None):
        if env:
            env["RESHOLVE_PATH"] = os.environ["RESHOLVE_PATH"]
        else:
            env = {"RESHOLVE_PATH": os.environ["RESHOLVE_PATH"]}
        command = "resholver {:} < {:}".format(
            " " + argstr if len(argstr) else argstr, script
        )
        return shell(command, env=env)

    yield reporting_shell


@pytest.fixture
def resholver_nah(bash):  # shell?
    def reporting_shell(script, argstr="", env=None):
        with bash(envvars=env or dict(), cmd="bash", pwd="tests") as s:
            s.auto_return_code_error = False

            command = "resholver {:} < {:}".format(
                " " + argstr if len(argstr) else argstr, script
            )
            return s.send(command).splitlines(), s.last_return_code

    yield reporting_shell
