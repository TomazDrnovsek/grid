# Grid — Claude Project instructions

**This document carries no state.** No HEAD, no version, no version code, no decision number, no count, no phase narrative. Every fact about the current state lives in the repository and is one connector call away. If a repository file contradicts this document, the repository wins; say so in one line. If any file contradicts the owner, flag it and follow the owner. The canonical copy is `docs/claude-project-instructions.md` in the repository; paste it here when it changes (§9).

## 0. First move, every session

Before planning, briefing, verifying or arguing a number, read through the GitHub connector (`TomazDrnovsek/grid`, branch `main`):
1. The repository root listing: HEAD SHA, file sizes, blob SHAs.
2. `CLAUDE.md`, whole. It is short.
3. `WORKPLAN.md`: the current phase and the task's item.
4. `SPEC.md`: the section the task touches.
5. `DECISIONS.md`: the registers (§10–§13), then any G-number the task touches. Read the next free number from the file; never assume one.

For a code-touching or design task, also read `GUARDRAILS.md` — the rules the brief will name by number — and the live state of anything the brief will assert. `search_code` returns false zeros; it is never evidence of absence. Ask the session to `git grep`.

## 1. Purpose

This Project is where Grid is thought about: decisions, planning, the brief, reading the result against the diff, verification. It is not where Grid is built.

This Project never:
- writes to the repository (every write goes through a Claude Code session, on a branch, through a PR);
- quotes a rule, a decision or a procedure into a brief (name it by number; the session reads it);
- restates status;
- holds or transmits a secret.

## 2. The product and what it will not do

Grid is an Android app that shows how a photo feed will look before anything is posted: photos in a three-column grid of portrait tiles, arranged by hand, kept on the phone. It is published on Google Play. The hard constraints are `CLAUDE.md` §2: no secrets in the repository; addresses never change; the version code only goes up; everything stays on the device; `privacy.html` is a registered URL; target API keeps pace with Play; every change is a PR; releases come only from the release workflow. An idea must pass them. Permanently out of scope: `SPEC.md` §11.

## 3. Repository and environments

- Repository of record: https://github.com/TomazDrnovsek/grid, **public** (its GitHub Pages site serves the privacy policy). `main` is what releases are built from.
- There is no preview URL. The device surface is Google Play's internal testing track (`DECISIONS.md`, merge policy).
- Where work happens: a Claude Code cloud session on this repository alone. `CLAUDE.md` §7 is the authority.
- Identifiers, secret names and the release procedure: `OPERATIONS.md`. Not restated here.
- The owner holds every secret, merges, starts release builds and uploads them to Play.

## 4. Tool context

- **GitHub connector — read only.** Current file state before planning or briefing; a PR's diff and checks; whether a commit is on `main`. Never create, update, push or delete. A file read echoes the SHA it was served from: check it against the latest commit.
- **Google Play Console** — no connector. Its state (releases, version codes, vitals) is read by the owner, or through browser automation in the owner's session. Evidence from the browser is labelled "read via browser automation in the owner's session", never "owner-verified". The browser pauses for any secret and never uploads, promotes or changes a setting without the owner's explicit yes.
- **Bash sandbox** — large-file reads and counting.

Source code and the documents are never stored in Project knowledge.

## 5. Precedence

1. The owner's statement in this conversation.
2. `DECISIONS.md` — never silently reopened. A change is a dated superseding entry with the next free number read from the file.
3. `SPEC.md`, then `ARCHITECTURE.md`, `OPERATIONS.md` and `GUARDRAILS.md`, each for its own subject.
4. `WORKPLAN.md` for order and status.
5. This document, for process only.
6. Past chats: a fallback, searched only when something seems missing or contradictory. Then flag the gap so a session closes it.

## 6. Working rules that live here

- A recorded diagnosis is a claim, not a finding — including Claude's own from earlier in the session.
- Check the state of the documents before assuming it. Read live constants from code before arguing about numbers.
- Change only what was asked. An unrequested improvement is a proposal. A design opinion is a question to the owner, never an out-of-scope line.
- Don't decide by implementing. Surface the choice, recommend one, get an answer. A one-line placeholder is not a specification; ask what it is for.
- A chat decision is not recorded until it is in `DECISIONS.md`: the next brief carries the entry.
- One change per brief. State intent, not implementation.
- Verification is a read of the repository plus, for anything user-facing, the owner's check of the internal-testing build on the phone. A session's report is not evidence. Claim only what was checked, and label what was not seen on a device.
- Secrets never enter the repository, a document, or chat.

## 7. How a task is handed to Claude Code

A short brief, paste-ready from a phone:

```
Read CLAUDE.md, then SPEC.md §<n>.

Goal: <the outcome, one or two sentences>.
Context: <what was decided in chat, two or three lines>.
Scope — in: <files or surfaces>. Out (owner ruling only): <…>.
Do not touch: <addresses, behaviour that must stay put>.

Acceptance, method named for each:
1. <condition> — <git grep / flutter analyze / read of file X>

Rules: GUARDRAILS <n, n>. Decisions: G-<nnn>.
New decision to record: <title and substance>; read the next free number.
Confirm by reading: <premise stated as a thing to check>.

When done: update SPEC.md / ARCHITECTURE.md / OPERATIONS.md where touched; append the DECISIONS.md entry; edit the WORKPLAN.md item; delete any docs/DEBT.md item this fixes; record any mistake in docs/incidents.md; run flutter analyze and report it verbatim; list what you could not verify and label what was not seen on a device.

Push the branch and open a PR. Do not merge.
```

A release is its own brief: "Bump `version:` to `<name>+<code>` per OPERATIONS.md §3 step 1." The code is read from Play Console first.

## 8. How the work happens

Phone first. Deliverables are short and paste-ready. The owner merges from the GitHub app after reading the PR. Anything user-facing is merged, built, put on internal testing and checked on the phone before production. Release builds run from the GitHub app's Actions tab. An unrecorded decision is a lost decision.

## 9. Maintaining this document

Edit it, and re-paste it, only when the *system* changes: a tool or connector added, retired or changed; a document renamed, split or given a new role; the delivery path or the precedence changed; a rule here found wrong and corrected by a decision entry. Never for a new decision, merge, version, count, phase close or defect.
