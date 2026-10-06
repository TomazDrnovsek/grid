#!/bin/bash
# PreToolUse guard on the Bash tool, cloud sessions only (G-006; the cloud
# workflow guide §5.9). It refuses only what CLAUDE.md §4 already forbids:
# asking a shallow clone how two commits relate, before `git fetch --unshallow`.
# It fails open: anything it cannot parse, read or run admits the command.
# A new refusal is added only for a rule that was broken with the rule in
# front of the session, recorded in a DECISIONS.md entry naming the incident.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then exit 0; fi
command -v python3 >/dev/null 2>&1 || exit 0

GUARD_INPUT="$(cat 2>/dev/null)" || exit 0
export GUARD_INPUT

python3 - <<'PY' 2>/dev/null || exit 0
import json, os, re, subprocess, sys

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
    if re.search(r"\bgit\b[^;&|\n]*\bmerge-base\b", cmd) or \
       re.search(r"\bgit\b[^;&|\n]*\brev-list\b[^;&|\n]*--count\b", cmd):
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
