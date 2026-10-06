# WORKPLAN.md — what is next, and its state

**Rules for writing here.**
1. The write that closes, adds, reorders or drops an item edits **the item's own line and checkbox**, in the same PR as the change. A narrative append is allowed in addition, never instead.
2. Grid does not number work orders: the PR is the unit (G-006). An item is named by its phase and its words.
3. Production version, version codes and HEAD are not facts this file carries; Play Console and GitHub are. Where a line records one, it records a dated pass.

Why is `DECISIONS.md`. How is `SPEC.md`, `ARCHITECTURE.md` and `OPERATIONS.md`. A one-line placeholder with no decision behind it is not a specification: before it is briefed, chat asks the owner what it is for.

## Current phase

Phase 2 — Carousels. Phase 1 — Release 1.0.4 (9) is complete: 1.0.4 (9) is in production (owner, 2026-10-06). Phase 0 is complete too.

## Phase map

- Phase 0 — Cloud migration
- Phase 1 — Release 1.0.4 (9)
- Phase 2 — Carousels

## Phase 0 — Cloud migration

- [x] Production source of 1.0.3 (6) committed from the owner's clone (G-006)
- [x] Document set, hooks, workflows, Jekyll exclusions (G-006, G-007, G-009)
- [x] Owner: the upload key and both passwords stored in the password manager (OPERATIONS §1; owner, 2026-10-06)
- [x] Owner: the three Actions secrets added (OPERATIONS §1)
- [x] Bootstrap PR #1 merged on the owner's instruction (2026-10-06). Privacy page checked live afterwards (200). The Pages deploy of that merge was still "waiting" with no approval offered — `docs/DEBT.md`
- [x] `docs/claude-project-instructions.md` in the Grid Project's instructions (read in the session context, 2026-10-06)
- [x] Hooks seen working in a live cloud session (2026-10-06): the SessionStart hook installed Flutter on resume; the guard refused a shallow-clone history query
- [x] `version: 1.0.3+7`, so the first CI build carries a new code — carried as the last commit of the bootstrap PR (OPERATIONS §3 step 1)
- [x] First `android-release` run green, certificate check passed, artifact `grid-1.0.3-7` (2026-10-06; validates `DECISIONS.md` §10 A-1). The run before it refused correctly while the secrets were missing
- [x] Bundle 7 rolled out to internal testing and installed on the owner's phone; the owner reported "it worked" (2026-10-06; validates A-2). Play automatic protection had to be turned off for the release (OPERATIONS §3 step 5)
- [x] 1.0.3 (7) does not go to production (owner, 2026-10-06): the menu still shows the hard-coded "Version 1.0.2" (`docs/DEBT.md`). Internal-test releases cannot be halted, so 7 stays on internal testing until a later code replaces it
- [x] Local clone at `C:\Users\tomaz\Documents\grid` archived (owner, 2026-10-06)

## Phase 1 — Release 1.0.4 (9)

- [x] Clear the fixable `docs/DEBT.md` items and bump to `version: 1.0.4+8`, PR from `claude/kind-turing-8l7s6o` (owner's brief, 2026-10-06): the real version on the menu and the Local Backup screen (G-012), the backup manifest's app version, a smoke test in the gate (G-013), `build.gradle`'s missing ProGuard file and comments, the unused `BackupCheckpoint`, the guard hook's quoted-text refusals. The highest code in Play Console is 7 (owner, 2026-10-06)
- [x] PR #4 merged on the owner's word (G-011), 2026-10-06
- [x] `android-release` run on `main` green, artifact `grid-1.0.4-8` (2026-10-06, run 37461406732 on `65c436a`; certificate check passed) (OPERATIONS §3 steps 2–4)
- [x] Bundle 8 is not uploaded: 1.0.4 ships once, as code 9 (owner, 2026-10-06)
- [x] The Android SDK script's mirror covers the Gradle Plugin Portal, PR #5 merged on the owner's word (2026-10-06)
- [x] Minimum SDK 24 so Play automatic protection stays on, and `version: 1.0.4+9` (G-014), PR from `claude/kind-turing-8l7s6o`
- [x] `android-release` run on `main` green, artifact `grid-1.0.4-9` (2026-10-06, run 37463669991 on `a4ab0ac`; certificate check passed) (OPERATIONS §3 steps 2–4)
- [x] Bundle 9 on internal testing, installed on the owner's phone; the menu and the Local Backup screen show `Version 1.0.4 (9)`; photos, order and profile survived the update (owner, 2026-10-06) (OPERATIONS §3 steps 5–6)
- [x] 1.0.4 (9) promoted to production (owner, 2026-10-06) (OPERATIONS §3 step 7)

## Phase 2 — Carousels

- [x] Design previews and flow diagram reviewed by the owner, choices answered (G-016; 2026-10-06)
- [x] Carousels: the "Add as" dialog, carousel tiles, the swipeable preview, delete and share of every slide, database version 3, manifest keys, How to Use Grid text (G-016), and `version: 1.0.5+10`, PR #10 from `claude/trusting-lamport-nmx81h`, merged on the owner's word (2026-10-06). The highest code in Play Console is 9, as recorded in Phase 1 (OPERATIONS §3 step 1)
- [x] `android-release` run 37489094908 on `main` dispatched by the session on the owner's word ("merge and build the aab.. v1.0.5", 2026-10-06). Bundle 10 is not uploaded: it shows the build code in the version line, which the owner ruled out (G-017)
- [ ] The version line shows the name only (G-017), and `version: 1.0.5+11`, PR from `claude/trusting-lamport-nmx81h`
- [ ] `android-release` run on `main` green, artifact `grid-1.0.5-11` (OPERATIONS §3 steps 2–4)
- [ ] Owner: bundle 11 on internal testing; carousels seen on a phone, including the update over an existing install and a backup and restore; the menu shows "Version 1.0.5" (G-010) (OPERATIONS §3 steps 5–6)
- [ ] Owner: 1.0.5 (11) promoted to production (OPERATIONS §3 step 7)

## Open decisions

`DECISIONS.md` §11. Not restated here.

## Blocked

Nothing.

## Carried unverified

`DECISIONS.md` §13.

## Backlog — each needs an owner brief before it is worked

- Automatic upload to Play internal testing (`DECISIONS.md` §12 D-1).

## Done log

- 2026-10-06 — Bootstrap onto the cloud-first workflow, PR from `claude/cloud-workflow-bootstrap` (G-006).
- 2026-10-06 — Debt items and `version: 1.0.4+8`, PR from `claude/kind-turing-8l7s6o` (G-012, G-013).
- 2026-10-06 — The Android SDK script's Maven Central mirror covers the Gradle Plugin Portal, PR from `claude/kind-turing-8l7s6o`.
- 2026-10-06 — Minimum SDK 24 and `version: 1.0.4+9`, PR from `claude/kind-turing-8l7s6o` (G-014).
- 2026-10-06 — 1.0.4 (9) in production; Phase 1 closed, PR from `claude/kind-turing-8l7s6o`.
- 2026-10-06 — `docs/DEBT.md` emptied: Pages item dropped, `photo_provider.g.dart` regenerated, privacy policy matches the manifest (G-015), PR from `claude/kind-turing-8l7s6o`.
- 2026-10-06 — Owner: the live privacy page shows the G-015 text, and the Play Data safety form matches it.
