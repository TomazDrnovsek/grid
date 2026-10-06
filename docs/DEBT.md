# docs/DEBT.md — known wrong, stale or unfinished

A working list, not a record. An item is added the moment it is found and **deleted** by the change that fixes it: no strikethroughs, no history. Each item is checkable: file, place, what is wrong. Not here: open questions (`DECISIONS.md` §11), unverified claims (`DECISIONS.md` §13), tastes.

- `lib/models/backup_models.dart` — `BackupCheckpoint` (with its generated code) is referenced nowhere else in `lib/`. It is either unfinished resumable-backup work or dead code; grep the whole repository before deciding (GUARDRAILS 3).
- GitHub Pages: the "pages build and deployment" run for merge `2a9a17a` (2026-10-06) built successfully, but its `deploy` job stayed "waiting" with no reviewers and no approve button. The site still serves the January deployment, so `privacy.html` is unaffected. Check whether the next merge deploys; if it also waits, look at Settings → Environments → `github-pages` and Settings → Pages.
- `.claude/hooks/guard-bash.sh` — the guard matches its two git commands anywhere in the command text, including inside a quoted string or heredoc that only mentions them, and refuses the whole command (observed 2026-10-06 on an edit script whose text named the command). The workaround is to put such text in a file. A fix should match only an actual invocation.
- `privacy.html` versus `AndroidManifest.xml` — the policy lists two permissions; the manifest declares four (`SPEC.md` §9). Changing the wording is owner-approved text (`DECISIONS.md` §11 O-3).
- `lib/ui/backup_settings_screen.dart` — the Local Backup screen has its own hard-coded version line, `'Version 1.0.1'` (found 2026-10-06 while fixing the menu's, G-012). It should read the same runtime source or go.
