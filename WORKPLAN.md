# WORKPLAN.md — what is next, and its state

**Rules for writing here.**
1. The write that closes, adds, reorders or drops an item edits **the item's own line and checkbox**, in the same PR as the change. A narrative append is allowed in addition, never instead.
2. Grid does not number work orders: the PR is the unit (G-006). An item is named by its phase and its words.
3. Production version, version codes and HEAD are not facts this file carries; Play Console and GitHub are. Where a line records one, it records a dated pass.

Why is `DECISIONS.md`. How is `SPEC.md`, `ARCHITECTURE.md` and `OPERATIONS.md`. A one-line placeholder with no decision behind it is not a specification: before it is briefed, chat asks the owner what it is for.

## Current phase

**Phase 0 — Cloud migration** (G-006). Done when a bundle built by the workflow is live and the local clone is retired.

## Phase map

- Phase 0 — Cloud migration
- Phase 1 — not yet defined. The candidates are in Backlog. Each needs an owner brief.

## Phase 0 — Cloud migration

- [x] Production source of 1.0.3 (6) committed from the owner's clone (G-006)
- [x] Document set, hooks, workflows, Jekyll exclusions (G-006, G-007, G-009)
- [ ] Owner: the upload key and both passwords stored in the password manager (OPERATIONS §1)
- [ ] Owner: the four Actions secrets added (OPERATIONS §1)
- [ ] Owner: the bootstrap PR reviewed and merged; Pages check passed (OPERATIONS §4)
- [ ] Owner: `docs/claude-project-instructions.md` pasted into the Grid Project; the workflow guide removed from Project knowledge
- [ ] A smoke-test cloud session started from claude.ai/code on this repository alone: the hook installs Flutter, and the gate runs green
- [ ] Release PR: `version: 1.0.3+7`, so the first CI build carries a new code (OPERATIONS §3 step 1)
- [ ] First `android-release` run green; the certificate check passed (validates `DECISIONS.md` §10 A-1)
- [ ] Bundle 7 uploaded to internal testing and installed on the phone; photos, order and profile intact (validates A-2)
- [ ] Decide whether 1.0.3 (7) goes to production. It is the same app as 6, rebuilt; promoting it is optional
- [ ] Local clone at `C:\Users\tomaz\Documents\grid` archived (renamed or zipped, not deleted) once the item above is done

## Open decisions

`DECISIONS.md` §11. Not restated here.

## Blocked

Nothing.

## Carried unverified

`DECISIONS.md` §13.

## Backlog — each needs an owner brief before it is worked

- Fix the debt items in `docs/DEBT.md` (each is a small PR).
- Replace the template widget test with a real smoke test, then add `flutter test` to the gate.
- Automatic upload to Play internal testing (`DECISIONS.md` §12 D-1).

## Done log

- 2026-10-06 — Bootstrap onto the cloud-first workflow, PR from `claude/cloud-workflow-bootstrap` (G-006).
