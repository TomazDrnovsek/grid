# docs/incidents.md — mistakes, in the order they happened

Every correction, mistake or blunder, numbered, recorded in the task it happened in (GUARDRAILS protocol 3). Read this when distilling a rule into `GUARDRAILS.md` Part II, not at the start of a task. Numbers are addresses: never renumbered.

Entry shape: **N — date — what happened.** *Effect.* *Cause.* *Fix.* *Rule it bears on.*

---

**1 — 2026-10-06 — A read-only git check left a lock file in the owner's clone.** While the owner's local folder was being inspected before the migration, `git status` was run on it through the desktop bridge, where file deletion is off by default. Git refreshes its index during a status and could not delete its own `.git/index.lock` afterwards.
*Effect.* An empty `.git/index.lock` was left behind, which would have blocked every later git operation in Android Studio on that clone. It was removed within minutes, after the owner granted delete permission for that purpose.
*Cause.* "Read-only" was assumed of a command that writes (GUARDRAILS 11, "a tool run for the first time in a repository may write into it").
*Fix.* Read another machine's repository with `git --no-optional-locks …`, or set `GIT_OPTIONAL_LOCKS=0`. Then check that no `.git/*.lock` remains.
*Rule.* GUARDRAILS 11. First instance.
