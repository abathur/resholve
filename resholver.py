#!/usr/bin/env python3
from __future__ import print_function

import sys
import os
import argparse
import logging

from collections import defaultdict
from distutils.spawn import find_executable

# just to support a rewritten variant of oil code (find_dynamic_token)
from typing import cast

# actual oil imports
from asdl import pybase  # CompoundObj

from core import alloc  # Arena
from core import error  # Parse, _ErrorWithLocation
from core import main_loop  # ParseWholeFile


from core import optview  # Parse

from core import ui  # PrettyPrintError
from osh import word_  # LeftMostSpanForWord, StaticEval

# LookupSpecialBuiltin, LookupAssignBuiltin, LookupNormalBuiltin, NO_INDEX
from frontend import consts
from frontend import parse_lib  # ParseContext
from frontend import reader  # FileLineReader (only into ParseContext().MakeOshParser)

from _devbuild.gen.id_kind_asdl import Id  # VSub_Number, VSub_Name, VSub_DollarName

from _devbuild.gen.syntax_asdl import (
    source,  # MainFile, Stdin
    word_part_e,  # ArithSub, AssocArrayLiteral, BracedVarSub, CommandSub, DoubleQuoted, EscapedLiteral, ExtGlob, Literal, ShArrayLiteral, SimpleVarSub, SingleQuoted, Splice, TildeSub
    command,  # ShFunction, Simple
    double_quoted,  # directly for cast()
    Token,  # directly for cast()
)

from tools import osh2oil  # Cursor

from mycpp.mylib import tagswitch  # only in find_dynamic_token


executables = dict()
resolved_scripts = dict()

logger = logging.getLogger(__name__)
logging.basicConfig(level=os.environ.get("LOGLEVEL", logging.CRITICAL))
# logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)

allowed_executable_varsubs = set()
# allowed_executable_varsubs = {"HOME", "PWD"}


parser = argparse.ArgumentParser(description="Resolve external dependencies.")
parser.add_argument(
    "scripts",
    metavar="SCRIPT",
    type=str,
    nargs="*",
    help="Script paths to resolve. Scripts in Nix build/store paths will be overwritten. Elsewhere, written to '<script>.resolved'. Pass script on <stdin> and redirect <stdout> if you need to control destination.",
)

# TODO: not really happy with this exemption mechanism. I like that it is explicit, but it doesn't scale well, and it's confounded by having different "kinds" of things that might all need exemptions. Yes, they *could* all use one namespace, but we're more likely to wrongly exempt something we didn't mean to that way...
parser.add_argument(
    "--allow",
    dest="allowed_executable_varsubs",
    action="append",
    metavar="VAR",
    help="allow dynamic statements consisting ONLY of a variable",
)

# TODO: not immediately essential, but I'd like to make some util/debug commands that represent what this script knows about the script(s) it has parsed. Like, the functions, command invocations, files sourced, etc. I just don't know exactly which information that is, how granular/modular, what format (just a simple text dump? json? etc.)


def lookup(word):
    if word not in executables:
        executables[word] = find_executable(word)
    return executables[word]


def resolve_script(script_path):
    if script_path in resolved_scripts:
        return resolved_scripts[script_path]

    resolved = resolved_scripts[script_path] = ResolvedScript(script_path)
    if script_path.startswith(os.environ["NIX_BUILD_TOP"]):
        logger.info(
            "script %r is located within nix build dir; overwriting", script_path
        )
        resolved.write_to(script_path)
    else:
        logger.info(
            "script %r not in Nix build dir; rewriting to: %s%s",
            script_path,
            script_path,
            ".resolved",
        )
        resolved.write_to(script_path + ".resolved")
    return resolved


def punshow():
    args = parser.parse_args()
    logger.debug("argparsed: %r", args)

    if args.allowed_executable_varsubs:
        allowed_executable_varsubs.update(args.allowed_executable_varsubs)

    # FAIR WARNING: config envs below will probably change.
    if "ALLOWED_VARSUBS" in os.environ:
        allowed_executable_varsubs.update(os.environ["ALLOWED_VARSUBS"].split())

    # this is a lie; we'll look up against PATH without it--but it might be a common mis-use?
    assert (
        "SHELL_RUNTIME_DEPENDENCY_PATH" in os.environ
    ), "SHELL_RUNTIME_DEPENDENCY_PATH must be set"

    # adopt the runtime dependency path for resolving external executables
    os.environ["PATH"] = os.environ["SHELL_RUNTIME_DEPENDENCY_PATH"]

    try:
        if len(args.scripts) == 0:
            resolved = ResolvedScript()
            # TODO: before this is okay, you've gotta move everything else that prints to a log, stderr, or a dynamic logging function that can choose depending on mode.
            resolved_scripts["<stdin>"] = resolved
            resolved.write_to()

        for script in args.scripts:
            resolved = resolve_script(os.path.abspath(script))

    except IOError as e:
        sys.stderr.write("whoooo buddy " + str(e))
        return 2
    except ResolutionError as e:
        e.print_if_needed()
        return e.exit_status
    except error._ErrorWithLocation as e:
        ui.PrettyPrintError(e)
        return e.exit_status
    # except Exception as e:
    #     raise e
    # I was doing the below, but I'm not sure why I wouldn't want to surface a real error here for now; it seems like this will only make debugging harder
    # print(type(e))
    # sys.stderr.write("whoooo buddy " + str(e))
    # return 2
    # print(len(resolved_scripts))
    # for script, resolver in resolved_scripts.items():
    #     print(script)
    #     print(resolver.funcs_defined)


def find_dynamic_token(part):
    # type: (word_part_t) -> token|bool
    """Recursive search for dynamic token.

    This is patterned on word_._EvalWordPart, but with
    ~inverted boolean logic: it returns the token object
    if one is found, otherwise False.
    """
    UP_part = part
    with tagswitch(part) as case:
        if case(word_part_e.ShArrayLiteral):
            return cast(Token, UP_part).token

        elif case(word_part_e.AssocArrayLiteral):
            return cast(Token, UP_part).token

        elif case(word_part_e.Literal):
            return False

        elif case(word_part_e.EscapedLiteral):
            return False

        elif case(word_part_e.SingleQuoted):
            return False

        elif case(word_part_e.DoubleQuoted):
            part = cast(double_quoted, UP_part)
            for p in part.parts:
                tok = find_dynamic_token(p)
                if tok:
                    return tok

            return False

        elif case(
            word_part_e.CommandSub,
            word_part_e.SimpleVarSub,
            word_part_e.BracedVarSub,
            word_part_e.TildeSub,
            word_part_e.ArithSub,
            word_part_e.ExtGlob,
            word_part_e.Splice,
        ):
            return cast(Token, UP_part).token
        else:
            raise AssertionError(part.tag_())


# before, we had to do optview.parse([False] * option_i.ARRAY_SIZE) and
# optview.Exec([False] * option_i.ARRAY_SIZE, errexit)
class FalseListFake(object):
    def __getitem__(self, option):
        return False


NO_OPTIONS = FalseListFake()


class ResolutionError(error._ErrorWithLocation):
    printed = False
    arena = None

    def __init__(self, *arg, **kwargs):
        self.arena = kwargs.pop("arena")
        error._ErrorWithLocation.__init__(self, *arg, **kwargs)

    def print_if_needed(self):
        if not self.printed:
            ui.PrettyPrintError(self, self.arena)
            self.printed = True


# We need to extract more info after hitting some firstwords
# This list is just for noticing if something is breaking expectations
WATCH_FIRSTWORDS = {"sudo", "command", "eval", "exec", ".", "source", "alias"}
KNOWN_BUILTINS = {
    ".",
    ":",
    "[",
    "alias",
    "bg",
    "bind",
    "break",
    "builtin",
    "caller",
    "cd",
    "command",
    "compgen",
    "complete",
    "compopt",
    "continue",
    "declare",
    "dirs",
    "disown",
    "echo",
    "enable",
    "eval",
    "exec",
    "exit",
    "export",
    "false",
    "fc",
    "fg",
    "getopts",
    "hash",
    "help",
    "history",
    "jobs",
    "kill",
    "let",
    "local",
    "logout",
    "mapfile",
    "popd",
    "printf",
    "pushd",
    "pwd",
    "read",
    "readarray",
    "readonly",
    "return",
    "set",
    "shift",
    "shopt",
    "source",
    "suspend",
    "test",
    "times",
    "trap",
    "true",
    "type",
    "typeset",
    "ulimit",
    "umask",
    "unalias",
    "unset",
    "wait",
}


class ResolvedScript(object):
    # basically:
    # - march through each command's first word
    # - separate builtins, functions, and commands
    # - record the position(s) of each builtin and command for easier replacing?
    # - resolve commands

    @staticmethod
    def _make_parser(parse_ctx, script, arena):
        """
        Do the last few steps to make a file-specific parser.
        """
        return parse_ctx.MakeOshParser(reader.FileLineReader(script, arena))

    def __init__(self, script_path=None):

        # generally, defer work until we know the script loaded
        with (open(script_path) if script_path else sys.stdin) as script:
            arena = alloc.Arena()
            parse_ctx = parse_lib.ParseContext(
                arena=arena,
                parse_opts=optview.Parse(NO_OPTIONS),
                aliases={},  # dummy
                oil_grammar=None,
            )
            parse_ctx.Init_OnePassParse(True)

            if script_path:
                # TODO: is there a real difference between using mainfile and
                # sourcedfile? (this gets re-used for sourced scripts)
                arena.PushSource(source.MainFile(script_path))
            else:
                arena.PushSource(source.Stdin())

            try:
                node = main_loop.ParseWholeFile(
                    self._make_parser(parse_ctx, script, arena)
                )
            except error.Parse as e:
                ui.PrettyPrintError(e, arena)
                raise

        assert node is not None

        # actually initialize
        self.arena = arena
        # TODO: not certain we don't want more, but minimize for now
        self.aliases = set()
        self.builtins = defaultdict(list)
        self.commands = defaultdict(list)
        self.sources = defaultdict(list)
        self.funcs_defined = set()
        self.resolved_commands = dict()
        self.resolved_functions = dict()
        self.resolved_aliases = dict()
        self.resolved_source = dict()
        self.parsed_source = dict()
        self.unresolved_commands = set()
        # unresolved functions doesn't make sense because we can't disambiguate an unresolved function from an unresolved external command...
        self.unresolved_source = set()
        self.word_obs = dict()

        # "resolve"
        try:
            self.Visit(node)
            self.resolve_records()
        except ResolutionError as e:
            e.print_if_needed()
            raise

        # TODO: this is convenient for debug, but I think this should be a separate call later. I'll have it return self so that it can be chained for simplicity.
        # self.render(out=sys.stdout)  # TODO: out to a sane file location?

    def write_to(self, path=None):
        f = open(path, "w") if path else sys.stdout
        try:
            return self.render(to=f)
        except ResolutionError as e:
            e.print_if_needed()
            raise

    def render(self, to=sys.stdout):
        cursor = osh2oil.Cursor(self.arena, to)

        replacements = {}

        # TODO: think about whether it's "right" to prefix builtins. I was
        # planning to do this because it reduces ambiiguity, increases
        # certainty, and I couldn't see a clear performance impact. But
        # patching them in bashup.events drops emits/s from ~13.9k to ~7.2k

        # for builtin, locations in self.builtins.items():
        #     for location in locations:
        #         replacements[location] = "builtin " + builtin

        for label, locations in self.sources.items():
            for location in locations:
                # the builtin replacement turned this into "builtin source"
                # this just patches the target
                replacements[location] = self.resolved_source[label]

        for command_word, locations in self.commands.items():
            target = None
            if command_word in self.resolved_commands:
                target = self.resolved_commands[command_word]
            else:
                if command_word in self.aliases:
                    logger.debug(
                        "Skipping %s alias: %s",
                        "resolved"
                        if command_word in self.resolved_aliases
                        else "unresolved",
                        command_word,
                    )
                    continue
                elif command_word in self.resolved_functions:
                    logger.debug("Skipping resolved functon: %s", command_word)
                    continue
                elif command_word in self.funcs_defined:
                    # we might not match a resolved function if it hasn't been looked up yet? I hope this doesn't happen, but if it did I guess we could force a lookup at this time.
                    raise Exception(
                        "function {:} defined but not resolved?".format(command_word)
                    )
                else:
                    raise ResolutionError(
                        "Can't resolve command %r to a known function or executable",
                        command_word,
                        word=self.word_obs[command_word],
                        status=2,
                        arena=self.arena,
                    )
            for location in locations:
                # TODO: think about whether it's 'right' to prefix commands.
                # ('command' or 'builtin command')
                # I was planning to do this to reduce ambiguity and initial
                # testing convinced me it was also faster, but revisiting it
                # per the builtin note above and it looks like the usual
                # exec time is something like:
                # bare (hashed) < absolute < bare(unhashed), and in all cases
                # prefixing the builtin added around ~1ms.
                #
                # Another reason to prefix would be to better support some
                # additional file parsing/modification/analysis (i.e.,
                # it's going to be hard for any tool without a full parser
                # to distinguish full command-paths written here from other
                # absolute paths.)
                #
                # I'm not sure there's a great way to triage the concerns, so
                # I'm inclined to prefer performance for now, and fall back on
                # prefixing if we find an actual reason to do it.
                replacements[location] = target

        order = sorted(replacements.keys())

        logger.info("Making replacements")
        logger.debug("The replacements are: %r", replacements)
        logger.debug("They'll be made in this order: %r", order)

        for location in order:
            cursor.PrintUntil(location)
            to.write(replacements[location])
            cursor.SkipUntil(location + 1)

        cursor.PrintUntil(self.arena.LastSpanId())
        self.arena.PopSource()
        return self

    def resolve_function(self, name):
        if name in self.funcs_defined:
            return self  # TODO: figure out proper return
        else:
            for res_source in self.parsed_source.values():
                resolved = res_source.resolve_function(name)
                if resolved:
                    return resolved
        return None

    def resolve_alias(self, name):
        if name in self.aliases:
            return self  # TODO: figure out proper return
        else:
            for res_source in self.parsed_source.values():
                resolved = res_source.resolve_alias(name)
                if resolved:
                    return resolved
        return None

    def resolve_records(self):
        global resolved_scripts
        logger.info("Resolving records")
        for res_source in self.resolved_source.values():
            logger.info("Parsing sourced script %r", res_source)
            resolved = self.__class__(res_source)
            resolved_scripts[res_source] = resolved
            self.parsed_source[res_source] = resolved
        # commands could be an external function or executable
        for command_word in self.commands.keys():
            if command_word.startswith("/"):
                # path is already properly resolved (probably by us)

                basecommand = os.path.basename(command_word)
                baseexecutable = lookup(basecommand)
                if command_word == baseexecutable:
                    continue
                    # it's okay that it's here. We don't need to replace it.
                else:
                    # or it's probably a hard-coded path
                    # TODO: also need to try and suss out things like $HOME/executable/path
                    raise ResolutionError(
                        # TODO: or we could give them a way to remap it here I guess.
                        # I'm just uncomfortable with the syntax paradigm that cleanly
                        # and efficiently expresses a complex set of ignore allow
                        # replace directives
                        "Unexpected absolute command path (not supplied by a listed dependency). You should patch/substitute it.",
                        # the others are errors too, but we'll just flag the first
                        span_id=self.commands[command_word][0],
                        arena=self.arena,
                    )

            executable = lookup(command_word)
            if executable:
                self.resolved_commands[command_word] = executable

            function = self.resolve_function(command_word)
            if function:
                self.resolved_functions[command_word] = function

            alias = self.resolve_alias(command_word)
            if alias:
                self.resolved_aliases[command_word] = alias

            if not function and not executable:
                self.unresolved_commands.add(command_word)

    def record_word(self, word_ob, text):
        global KNOWN_BUILTINS
        pos = word_.LeftMostSpanForWord(word_ob)
        self.word_obs[text] = word_ob
        # TODO: this did look up builtins oil's way
        # but the list of builtins there are probably
        # oil's:
        # if (
        #     consts.LookupSpecialBuiltin(text) == consts.NO_INDEX
        #     and consts.LookupAssignBuiltin(text) == consts.NO_INDEX
        #     and consts.LookupNormalBuiltin(text) == consts.NO_INDEX
        # ):
        #
        # The ~most-right way to do this would probably be to get the builtins from the target shell (at build-time? call-time?) but I'm not sure there's a portable way to do that?
        # If there was, the Nix side could accept a shell (or shells?) argument, try to run that command in each, merge the lists, and supply t hem.
        #
        # For now, I'm just hard-coding a list of bash builtins (from compgen -b in GNU bash, version 5.0.9(1)-release (x86_64-apple-darwin17.7.0))
        if text not in KNOWN_BUILTINS:
            logger.info("Recording command: %r", text)
            logger.debug("   position: %d, word object: %r", pos, word_ob)
            self.commands[text].append(pos)
        else:
            # TODO: no immediate use since I'm no longer patching builtins
            # but there may still be utility in recording builtins a script
            # depends on. This would support spotting function/alias
            # clashes and such.
            self.builtins[text].append(pos)

    def record_source(self, word_ob, text, target):
        pos = word_.LeftMostSpanForWord(word_ob)
        logger.info("Recording source: %r -> %r", text, target)
        logger.debug("   position: %d, word object: %r", pos, word_ob)
        self.word_obs[text] = word_ob
        self.sources[text].append(pos)
        self.resolved_source[text] = target

    def _visit_command_Simple(self, node):
        if not node.words:
            return

        w_ob1 = node.words[0]
        ok1, word1, _ = word_.StaticEval(w_ob1)
        if not ok1:
            logger.debug(
                "Couldn't statically evaluate 1st word object of command: %r", w_ob1
            )
            return
        else:
            self.record_word(w_ob1, word1)

        # If there's a second word, let's go ahead and pop it off.
        # We don't know we need it, but enough cases do that it's easier.
        if len(node.words) > 1:
            w_ob2 = node.words[1]
            ok2, word2, _ = word_.StaticEval(w_ob2)
            # we don't care if it succeeded, yet
        else:
            if word1 in WATCH_FIRSTWORDS:
                # just a chance to bail out on a broken script
                # may not be worth the code...
                raise Exception(
                    "Trying to handle {:} but it lacks a required argument".format(
                        word1
                    ),
                    node,
                )

        # CAUTION: some prefixable commands/builtins are ~infinitely nestable.
        # "builtin builtin builtin builtin builtin command whoami" is perfectly valid.
        # The current code won't see the dep on an external command 'whoami'.

        # TODO: Does it make sense to use the presence buildin/command etc
        # as smells that trigger extra scrutinty? i.e., "builtin source" may
        # be a reasonable smell that the script or something it sources overrides
        # source?

        # TODO: should builtin be here? Currently not because we don't want to replace them...
        if word1 in (".", "source", "sudo", "command", "eval", "exec", "alias"):
            logger.info("Visiting command: %s %s", word1, word2)
            if not ok2:
                logger.info("   Command is dynamic")
                # DEBUG: print(node)
                for part in w_ob2.parts:
                    bad_token = find_dynamic_token(part)
                    if bad_token:
                        # Letting $1-style subs through for now. There are
                        # In practice, these could be paths we want to
                        # resolve, *or* be perfectly fine as is.
                        if bad_token.id == Id.VSub_Number:
                            # TODO: if there's a good way to walk back out
                            # could record the outer context as sourcing
                            # its arguments. But the naive version doesn't
                            # give us much more than outright rejecting here.
                            # A non-naive version would need to figure out
                            # which numbered argument it was, be able to figure
                            # out if set/shift were used to fiddle with it,
                            # and walk it all the way back out to the string
                            # passed into the original function call to treat
                            # *that* as the token to resolve.
                            return
                        # TODO: practice below mostly considers part vars like
                        # $HOME/blah or $PREFIX/blah, but there are other
                        # patterns a more sophisticated version could address.
                        # At the moment those would need to be manually
                        # patched. I'd like to follow this definition back to
                        # the vardef and register it for substitution if it's
                        # a simple string, flatten here and reconsider.

                        # Letting ${name}-style subs through only if they're in
                        # a list of allowed names. (goal: require conscious
                        # exceptions, but make them easy to add)
                        elif (
                            bad_token.id == Id.VSub_Name
                            and bad_token.val in allowed_executable_varsubs
                        ):
                            return
                        # Letting $name-style subs through only if they're in
                        # a list of allowed names. (goal: require conscious
                        # exceptions, but make them easy to add)
                        elif (
                            bad_token.id == Id.VSub_DollarName
                            # [1:] to leave off the $
                            and bad_token.val[1:] in allowed_executable_varsubs
                        ):
                            return
                        else:
                            raise ResolutionError(
                                # TODO: crap phrasing
                                "Can't resolve %r with an argument that can't be statically parsed",
                                w_ob1.parts[0].val,
                                word=w_ob2,
                                token=bad_token,
                                status=2,
                                arena=self.arena,
                            )

                raise Exception(
                    "Not sure. I thought 'ok' was only False when we hit a dynamic token, but we just searched for a dynamic token and didn't find one. Reconsider everything you know.",
                    part,
                    w_ob2,
                )
            else:
                logger.info("   Command is static")
                # No magic
                if word1 in ("sudo", "command", "eval", "exec"):
                    self.record_word(w_ob2, word2)
                elif word1 in (".", "source"):
                    # CAUTION: in a multi-module library, we'll have to think very carefully about how to look up targets in order to parse them, but *avoid* translating the source statement into an absolute URI. (If this is sticky, another option might be a post-substitute to replace the build-path with the output path?)
                    target = lookup(word2)
                    logger.debug("Looked up source: %r -> %r", word2, target)
                    # it was already a valid absolute path
                    if target == word2 and target[0] == "/":
                        # TODO: I'm not sure if we should do anything about absolute paths
                        # but if so, this is where we'd do it.
                        # raise ResolutionError(
                        #     "Do we want to object to absolute paths like %r ?",
                        #     word2,
                        #     word=w_ob2,
                        #     status=2,
                        # )
                        self.record_source(w_ob2, word2, target)
                    # it seems to resolve relative filenames for files in the current
                    # directory, no matter what path is set to...
                    elif target == word2:
                        # TODO: I guess these all need to get prefxed with $out?
                        self.record_source(w_ob2, word2, target)
                    # it resolved to a new location
                    elif target:
                        self.record_source(w_ob2, word2, target)
                    # It didn't resolve, or it was an invalid absolute path
                    else:
                        # self.unresolved_source.add(target)
                        # I was recording this, but maybe we should just raise an exception
                        raise ResolutionError(
                            "Unable to resolve source target %r to a known file",
                            word2,
                            word=w_ob2,
                            status=2,
                            arena=self.arena,
                        )
                elif word1 == "alias":
                    # try to handle all observed alias representations
                    alias = word2.strip("\"='").split("=")[0]
                    self.aliases.add(alias)
                    # TODO: not sure this is the right thing to store here. Could be a set? Could save the expansion?

    def _visit_command_ShFunction(self, node):
        self.funcs_defined.add(node.name)

    def _Visit(self, node):
        cls = node.__class__
        if cls is command.Simple:
            self._visit_command_Simple(node)

        elif cls is command.ShFunction:
            self._visit_command_ShFunction(node)

    def Visit(self, node):
        self._Visit(node)
        self.VisitChildren(node)

    # borrowed from Visitor in tools/deps.py
    # seems like a lot to import for...
    def VisitChildren(self, node):
        """
        Args:
          node: an ASDL node.
        """

        for name in node.__slots__:
            child = getattr(node, name)
            if isinstance(child, list):
                for item in child:
                    if isinstance(item, pybase.CompoundObj):
                        self.Visit(item)
                continue

            if isinstance(child, pybase.CompoundObj):
                self.Visit(child)
                continue


if __name__ == "__main__":
    sys.exit(punshow())
