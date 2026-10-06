# Grid — session contract

Read this file whole; it is short on purpose. Then, for a task: the `SPEC.md` section it touches, the `GUARDRAILS.md` rules the brief names by number, the `DECISIONS.md` entries it cites, and its `WORKPLAN.md` item. Precedence and the document map are in §9.

## 1. What this is

Grid is an Android app for planning a photo feed: the owner of a social profile imports photos, arranges them in a three-column grid that shows how the feed will look, and keeps everything on the phone. It is published on Google Play as `si.tomazdrnovsek.grid`.

Stack: Flutter 3.32.8 (Dart 3.8.1), Riverpod 2, freezed, sqflite, a Kotlin `MethodChannel` for Storage Access Framework backups. What it does: `SPEC.md`. How it is built: `ARCHITECTURE.md`. How it is released and run: `OPERATIONS.md`.

`README.md` is not documentation. It is the index page GitHub Pages serves for this repository, and it stays as it is until an entry in `DECISIONS.md` changes it (open register, `DECISIONS.md` §11).

## 2. Hard constraints

These hold until a dated entry in `DECISIONS.md` says otherwise. If a task requires breaking one, say so and stop rather than breaking it quietly.

1. **No secret enters the repository**: no keystore, no password, no `key.properties`, no service-account file. Signing material lives in GitHub Actions secrets and the owner's password manager (G-007).
2. **Addresses never change** (§6). Users' photos, saves and backups depend on them.
3. **The version code only goes up.** It is the `+N` of `version:` in `pubspec.yaml` (G-005). It must exceed every code already uploaded to Play; Play Console is the authority on which codes are used.
4. **Everything stays on the device.** No analytics, ads, tracking, accounts or uploads by the app. The only network use is opening an external link. A change to this also changes `privacy.html` and the Play Data safety form, both owner-approved.
5. **`privacy.html` is the live privacy-policy URL registered in Play Console**, served by GitHub Pages from `main` (G-003). Never move, rename or delete it. Its text changes only with the owner's explicit approval, quoted in the PR. The repository stays public while Pages serves it.
6. **The target API level meets Google Play's current requirement** (G-004).
7. **Every change is a branch and a PR.** Nothing is pushed to `main` directly. The owner decides when a PR merges; a session merges it only when the owner tells it to in the conversation (G-011).
8. **Release bundles come only from the `android-release` workflow run on `main`** (G-007). A session never produces a bundle for upload and never handles the real key.

## 3. Commands

In a cloud session the SessionStart hook (`.claude/hooks/session-start.sh`) installs Flutter 3.32.8 and runs `flutter pub get`. It takes a few minutes on a fresh machine.

- **Gate:** `flutter analyze`, then `flutter test` (G-013). Healthy output: `No issues found!`, then `All tests passed!`. CI runs both on every PR (`.github/workflows/quality.yml`).
- **Code generation** after editing a `@freezed`, `@riverpod` or `@JsonSerializable` source: `dart run build_runner build --delete-conflicting-outputs`. The generated `*.freezed.dart` and `*.g.dart` files are committed.
- **Android compile check** (optional; not a release): `bash docs/tools/android-sdk.sh` once per machine, then `flutter build apk --debug`. The first run downloads the SDK, NDK 27.0.12077973 and CMake, which takes several minutes.

A green gate is a floor, never a verdict. The only screen an automated check mounts is the splash (`test/widget_test.dart`); none touches a photo. Anything a user sees is unverified until it has been seen on a phone.

## 4. Working rules

- Change only what was asked (GUARDRAILS 1). An improvement you notice is a proposal in the report, not a change.
- Grep before scoping anything shared. A search returning zero is not absence (GUARDRAILS 3).
- A recorded diagnosis — in `DECISIONS.md`, `docs/DEBT.md`, a comment or a brief — is a claim. Verify the symptom before fixing the stated cause.
- Do not invent design decisions. Take the smallest plausible choice and flag it at the top of the report as unmade.
- Verify what you claim and say how. Say what you could not see. Label everything not seen on a device "not seen on a device".
- Never silently reopen a decision. A change is a dated superseding entry in `DECISIONS.md`.
- A comment that describes behaviour the code no longer has is a defect. Fix it in the same change.
- The checkout is a shallow clone. Run `git fetch --unshallow` before any conclusion about how two commits relate. The guard hook refuses `git merge-base` and `git rev-list --count` until then.
- Update the documents in the same change (§5). Record any mistake in `docs/incidents.md` in the task it happened in.
- Line endings are LF everywhere (`.gitattributes`).
- Count words drift: point at where a number lives instead of writing it down.

## 5. Definition of done — the same-PR rule

A change is finished when the PR that carries it also carries every document it made stale.

| If the change… | then the same PR updates… |
| --- | --- |
| alters what the app does or how it is built | `SPEC.md` and/or `ARCHITECTURE.md`, present tense, citing the decision |
| settles a question, reverses a design, drops an item | a dated `DECISIONS.md` entry, next free G-number read from the file |
| closes, adds, reorders or drops a task | the item's own line and checkbox in `WORKPLAN.md` |
| fixes something listed in `docs/DEBT.md` | **deletes** that item |
| touches the release procedure, a secret's name, an identifier | `OPERATIONS.md` |
| involved a mistake, a wrong diagnosis, a corrected premise | `docs/incidents.md`, same task |
| edits a generated-code source | the regenerated files |
| is a release | `pubspec.yaml` `version:` (name and code), per `OPERATIONS.md` §3; the report gives the owner release notes ready to paste (`OPERATIONS.md` §3 step 5) |

Then: the gate is green, the PR is open, the CI result is read (the failing step, if red), and the report says what was verified and how, with any unmade decision at the **top**. Commit subjects are imperative (`Fix the hue map toggle on restore`). Push the branch and open a PR. Do not merge unless the owner tells you to (G-011).

## 6. Addresses that never change

- Application id and namespace `si.tomazdrnovsek.grid`; Kotlin package `si.tomazdrnovsek.grid`.
- `MethodChannel` name `com.grid/saf` and its method names (`lib/repositories/saf_storage_provider.dart` ↔ `MainActivity.kt`).
- SQLite database file `photos.db` and its schema (`lib/services/photo_database.dart`). A shipped table or column is never renamed, removed or given a new meaning. A new one arrives only through a versioned, additive migration that leaves every existing row's values as they were (G-016).
- SharedPreferences keys, read live: `git grep -nE "static const String _[a-zA-Z]*[Kk]ey"` in `lib/`. That includes the legacy keys a migration still reads.
- The backup folder layout and `manifest.json` / `manifest.json.tmp` names and format (`lib/repositories/cloud_manifest_repository.dart`, `lib/models/backup_models.dart`). A shipped key keeps its name and meaning. A new key is optional, and `version` stays 1 while older app versions must still read the backup (G-016).
- `privacy.html` at the repository root.
- The upload key alias `upload`, and the three Actions secret names in `OPERATIONS.md` §1.

Words, which may change: the app's display name, copy, the repository name.

## 7. Where work happens

- **Cloud session by default**, from claude.ai/code or the Claude mobile app, on a `claude/…` branch. No local clone is required, and none is privileged.
- **Chat (the Claude Project)** thinks, plans and writes briefs. It reads the repository; it never writes to it.
- **The owner** decides merges (G-011), installs test builds from Play's internal testing track on a phone, starts release builds, uploads them in Play Console, holds every secret, and decides what reaches production.
- **Releases:** `OPERATIONS.md` §3.

## 8. Session gotchas

- **Maven Central answers 429 to the cloud sandbox's shared egress** (observed 2026-10-06). `docs/tools/android-sdk.sh` installs a Gradle init script that sends Maven Central traffic to Google's public mirror of it, outside the repository. That covers plugin resolution too, where the Gradle Plugin Portal redirects to Maven Central. GitHub's runners are not affected.
- **A release build without `android/key.properties` fails at `:app:signReleaseBundle` with a bare `NullPointerException`.** That is the missing key, not a code fault. Debug builds don't need a key.
- `flutter` prints a warning about running as root in a cloud session. It is harmless.
- `build/` and `android/build/` are outputs and are ignored.
- Repository hooks run only in a session opened on this one repository.
- A session may be refused permission to edit `.claude/settings.json`. Stop and say so; the owner's "proceed" clears it.
- State lives in three places, not one. Photo and backup state are Riverpod providers (`lib/providers/`). The services (database, thumbnails, image cache, performance monitor, scroll optimiser) sit in a service locator (`lib/core/service_locator.dart`). The theme is a plain `ThemeNotifier` created in `lib/main.dart` and passed down by constructor. Check all three before concluding where something lives.

## 9. Document map and precedence

| File | Holds | Does not hold |
| --- | --- | --- |
| `CLAUDE.md` | This contract: constraints, commands, rules, addresses | Status, counts, history |
| `SPEC.md` | What the app does now, its vocabulary, what it will not do | Why (→ DECISIONS), how (→ ARCHITECTURE) |
| `DECISIONS.md` | Why: numbered G- entries; the registers of assumptions, open questions, deferrals and unverified claims | Task status |
| `WORKPLAN.md` | What is next and its state; the Done log | Rationale |
| `ARCHITECTURE.md` | How it is built: stack with proving files, data, packaging, quality gate, delivery | Release steps (→ OPERATIONS) |
| `OPERATIONS.md` | Identifiers, secret names (never values), the release procedure, runbooks | Secret values |
| `GUARDRAILS.md` | Failure patterns and the rules against them | The incident narrative (→ docs/incidents.md) |
| `docs/DEBT.md` | Known wrong, stale or unfinished things that are not decisions; deleted when fixed | Open questions, unverified claims |
| `docs/incidents.md` | Every mistake, in order | Rules |
| `docs/claude-project-instructions.md` | The chat Project's instructions, state-free | State |
| `docs/history/` | Verbatim records superseded by the documents above | Authority |

**Precedence when files disagree:** the owner's statement · `DECISIONS.md` on settled questions · `SPEC.md`, then `ARCHITECTURE.md`, `OPERATIONS.md` and `GUARDRAILS.md`, each for its own subject · `WORKPLAN.md` for order and status · this file for implementation. If a file contradicts the owner, say so in one line and follow the owner.

## 10. Task shape that works here

Good: *"Show the real version name on the menu screen instead of the hard-coded one. Scope: `lib/ui/menu_screen.dart`; `SPEC.md` §8. Rules: GUARDRAILS 1, 3. Delete the matching `docs/DEBT.md` item."*

Bad: *"Make the grid better."* Bad: *"Clean up the code."* If a task is that broad, ask for the `SPEC.md` section or the `WORKPLAN.md` item it serves, or propose a scoped version and wait.
