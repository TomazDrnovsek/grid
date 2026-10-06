#!/bin/bash
# PreToolUse guard on the Bash tool, cloud sessions only (G-006; the cloud
# workflow guide §5.9). It refuses only what CLAUDE.md §4 already forbids:
# asking a shallow clone how two commits relate, before `git fetch --unshallow`.
# It refuses an invocation, not a mention: the command is split into shell
# words, so text in quotes, a heredoc or a comment that only names the git
# command is admitted. What would run is still checked: $(...), backticks,
# an unquoted heredoc's expansions, `bash -c` / `sh -c` scripts and `eval`.
# It fails open: anything it cannot parse, read or run admits the command.
# A new refusal is added only for a rule that was broken with the rule in
# front of the session, recorded in a DECISIONS.md entry naming the incident.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then exit 0; fi
command -v python3 >/dev/null 2>&1 || exit 0

GUARD_INPUT="$(cat 2>/dev/null)" || exit 0
export GUARD_INPUT

python3 - <<'PY' 2>/dev/null || exit 0
import json, os, re, subprocess, sys

SEPARATORS = set(";&|()\n")
BLANKS = set(" \t\r")
KEYWORDS = {"{", "}", "!", "if", "then", "else", "elif", "do", "while", "until", "time"}
WRAPPERS = {"sudo", "env", "command", "builtin", "exec", "nohup", "nice", "xargs", "timeout"}
SHELLS = {"bash", "sh", "zsh", "dash", "ksh"}
GIT_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path", "--config-env"}
ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
NUMBER = re.compile(r"^[0-9.]+[smhd]?$")       # timeout's duration, nice's level
MAX_DEPTH = 8


def substitution(text, i):
    """text[i:] follows '$('. Return (inner text, index after the closing ')')."""
    depth, j, n = 1, i, len(text)
    while j < n:
        c = text[j]
        if c == "\\":
            j += 2
            continue
        if c == "'":
            j = text.index("'", j + 1) + 1
            continue
        if c == '"':
            j += 1
            while text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            j += 1
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return text[i:j], j + 1
        j += 1
    raise ValueError("unterminated $(")


def expansions(text, depth):
    """Commands run by $(...) and backticks in text that the shell expands
    (double-quoted text, an unquoted heredoc's body)."""
    found, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == "\\":
            i += 2
        elif c == "$" and text[i + 1:i + 2] == "(":
            inner, i = substitution(text, i + 2)
            found += commands(inner, depth + 1)
        elif c == "`":
            end = text.index("`", i + 1)
            found += commands(text[i + 1:end], depth + 1)
            i = end + 1
        else:
            i += 1
    return found


def commands(text, depth=0):
    """Split shell text into the simple commands it would run, as word lists."""
    if depth > MAX_DEPTH:
        return []
    found, words, word = [], [], None
    heredocs = []          # (delimiter, strip_tabs, expands)
    skip_next = False      # the next word is a redirection target
    i, n = 0, len(text)

    def end_word():
        nonlocal word, skip_next
        if word is not None:
            if skip_next:
                skip_next = False
            else:
                words.append(word)
        word = None

    def end_command():
        nonlocal words
        end_word()
        if words:
            found.append(words)
        words = []

    while i < n:
        c = text[i]
        nxt = text[i + 1:i + 2]
        if c in BLANKS:
            end_word()
            i += 1
        elif c == "\\":
            if nxt != "\n":
                word = (word or "") + nxt
            i += 2
        elif c == "'":
            end = text.index("'", i + 1)
            word = (word or "") + text[i + 1:end]
            i = end + 1
        elif c == '"':
            j, buf = i + 1, ""
            while text[j] != '"':
                if text[j] == "\\" and text[j + 1] in '$`"\\\n':
                    buf += text[j + 1]
                    j += 2
                elif text[j] == "$" and text[j + 1:j + 2] == "(":
                    inner, j = substitution(text, j + 2)
                    found += commands(inner, depth + 1)
                elif text[j] == "`":
                    end = text.index("`", j + 1)
                    found += commands(text[j + 1:end], depth + 1)
                    j = end + 1
                else:
                    buf += text[j]
                    j += 1
            word = (word or "") + buf
            i = j + 1
        elif c == "$" and nxt == "(":
            inner, i = substitution(text, i + 2)
            found += commands(inner, depth + 1)
            word = word or ""
        elif c == "`":
            end = text.index("`", i + 1)
            found += commands(text[i + 1:end], depth + 1)
            word = word or ""
            i = end + 1
        elif c == "#" and word is None:
            while i < n and text[i] != "\n":
                i += 1
        elif c == "<" and text[i:i + 2] == "<<" and text[i:i + 3] != "<<<":
            end_word()
            i += 2
            strip_tabs = text[i:i + 1] == "-"
            if strip_tabs:
                i += 1
            while i < n and text[i] in BLANKS:
                i += 1
            delim, expands = "", True
            while i < n and text[i] not in BLANKS and text[i] not in SEPARATORS and text[i] not in "<>":
                if text[i] in "'\"":
                    expands = False
                    end = text.index(text[i], i + 1)
                    delim += text[i + 1:end]
                    i = end + 1
                elif text[i] == "\\":
                    expands = False
                    delim += text[i + 1:i + 2]
                    i += 2
                else:
                    delim += text[i]
                    i += 1
            heredocs.append((delim, strip_tabs, expands))
        elif c in "<>" or (c == "&" and nxt == ">"):
            end_word()
            i += 1
            while i < n and text[i] in "<>&|":
                i += 1
            skip_next = True
        elif c in SEPARATORS:
            end_command()
            i += 1
            if c == "\n":
                for delim, strip_tabs, expands in heredocs:
                    body = []
                    while i < n:
                        end = text.find("\n", i)
                        end = n if end < 0 else end
                        line = text[i:end]
                        i = end + 1
                        if (line.lstrip("\t") if strip_tabs else line) == delim:
                            break
                        body.append(line)
                    if expands:
                        found += expansions("\n".join(body), depth)
                heredocs = []
        else:
            word = (word or "") + c
            i += 1
    end_command()
    return found


def refused(words, depth=0):
    i = 0
    while i < len(words):
        w = words[i]
        if ASSIGNMENT.match(w) or w in KEYWORDS or w in WRAPPERS or w.startswith("-") or NUMBER.match(w):
            i += 1
            continue
        break
    if i >= len(words):
        return False
    name, args = os.path.basename(words[i]), words[i + 1:]
    if name in SHELLS:
        for k, a in enumerate(args):
            if re.match(r"^-[A-Za-z]*c[A-Za-z]*$", a) and k + 1 < len(args):
                return any(refused(cmd, depth + 1) for cmd in commands(args[k + 1], depth + 1))
        return False
    if name == "eval":
        return any(refused(cmd, depth + 1) for cmd in commands(" ".join(args), depth + 1))
    if name != "git":
        return False
    j = 0
    while j < len(args):
        if args[j] in GIT_OPTS_WITH_VALUE:
            j += 2
        elif args[j].startswith("-"):
            j += 1
        else:
            break
    if j >= len(args):
        return False
    sub, rest = args[j], args[j + 1:]
    return sub == "merge-base" or (sub == "rev-list" and "--count" in rest)


try:
    data = json.loads(os.environ.get("GUARD_INPUT", ""))
    cmd = data.get("tool_input", {}).get("command", "")
    if not isinstance(cmd, str) or not cmd:
        sys.exit(0)
    root = os.environ.get("CLAUDE_PROJECT_DIR") or subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5).stdout.strip()
    if not root or not os.path.exists(os.path.join(root, ".git", "shallow")):
        sys.exit(0)
    if any(refused(words) for words in commands(cmd)):
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Refused by .claude/hooks/guard-bash.sh: this checkout is a shallow clone "
                "(.git/shallow exists), so git merge-base and git rev-list --count give "
                "false answers about how commits relate (CLAUDE.md §4). Run "
                "`git fetch --unshallow` first, then retry."),
        }}))
except SystemExit:
    raise
except Exception:
    sys.exit(0)
PY
exit 0
