# DECISIONS.md — why Grid is the way it is

**Rules for this file.**
- These are decisions that future work must not silently reopen. A decision changes only through a new dated entry that supersedes it; the superseded entry is reduced to a row in the index (§9).
- Identifiers are `G-nnn`. They are addresses: never renumbered, never reused, never edited after the fact except to add a pointer to what superseded them.
- **The next free number is read from this file** (the highest `G-` heading plus one). There is no count to read.
- Entries G-001 to G-005 are **reconstructed**: written on 2026-10-06 from the code, the git history, the Play Console and the owner's local clone, describing choices made before this file existed. Each says what it was read from. Treat their *Why* lines as the best available reading, not as the owner's words.

Entry shape: *What changed* · *Why* · *What is settled* · *What is not settled* · *Verified* · *Paths not taken*. Not every entry needs every heading.

## Product and platform

**G-001 — Grid is a local-only photo-feed planner for Android, built in Flutter (reconstructed; built from 2025-07-26).** The owner designed and directs it. It was built with AI coding tools on his Windows machine. Its first bundle (1.0.0, code 1) was uploaded to a Google Play closed testing track on 25 Aug 2025.

*What is settled.* Flutter, Android as the only shipped platform, everything on the device (CLAUDE.md constraint 4). `SPEC.md` describes the app as built.
*Verified.* Read from `lib/`, `pubspec.yaml`, `AndroidManifest.xml`, and the git history (first commit 2025-07-26, "Release Version 1.0.0" 2025-08-25).
*Not verified.* The app's behaviour on a device while `SPEC.md` was being written.

**G-002 — The application id is `si.tomazdrnovsek.grid`, and Play App Signing holds the app signing key (reconstructed; 2025-08-24/25).** Google Play holds the app signing key. The owner signs each upload with an upload key: alias `upload`, PKCS12, created 24 Aug 2025, valid until 2053. Its certificate fingerprints are in `OPERATIONS.md` §1.

*What is settled.* The id is an address (CLAUDE.md §6). The upload key is the only key a release is signed with. Losing it is recoverable through Play Console's upload-key reset, at the cost of time (`OPERATIONS.md` §5).
*Verified (2026-10-06).* The upload key certificate shown in Play Console → App integrity matches the keystore on the owner's clone (SHA-1 and SHA-256). The bundle of production 1.0.3 (6) on that clone carries the same certificate.

**G-003 — The privacy policy is `privacy.html` at the repository root, served by GitHub Pages, so the repository stays public (reconstructed; 2025-08-25).** Play Console's privacy-policy URL is `https://tomazdrnovsek.github.io/grid/privacy.html`. GitHub Pages serves it from this repository's root with Jekyll.

*What is settled.* The file's path is an address. The repository stays public: on GitHub's free plan, Pages does not serve private repositories. The cloud-first guide's "private repository" default is set aside for Grid on this ground.
*Verified (2026-10-06).* The URL read in Play Console → App content → Privacy policy. The page answered 200 with the policy; the Pages root answered 200 with Jekyll's rendering of `README.md`.
*Paths not taken.* A private repository with the policy hosted elsewhere: it changes a registered URL for no product gain.

**G-004 — Compile and target SDK 36, minimum SDK 21 (reconstructed; shipped 2026-07-22 in 1.0.3 (6)).** Set on the owner's clone in a 2026-07-22 session with Google's Antigravity agent (its notes are kept verbatim in `docs/history/2026-07-22-antigravity/`).

*Why.* Target 36 is Google Play's requirement for new apps and updates from 31 Aug 2026. `minSdk 21` was set explicitly after Play Console reported a large drop in supported devices. The session's notes give the reason as Flutter's default minimum moving up; that diagnosis is the session's, not verified here.
*What is settled.* Target API keeps pace with Play's requirement (CLAUDE.md constraint 6).
*Verified (2026-10-06).* The production bundle's manifest reads `minSdkVersion 21`, `targetSdkVersion 36`, version code 6, name 1.0.3.
*Paths not taken.* `abiFilters` to force 32-bit ABIs was proposed in the same session's plan and is not in the shipped `build.gradle`.

**G-005 — `pubspec.yaml` `version:` is the single source of the version name and code (reconstructed; 2026-07-22).** `android/app/build.gradle` reads `flutter.versionCode` and `flutter.versionName`, which Flutter writes from `pubspec.yaml`. Before this, the code and name were hard-coded in `build.gradle` and had drifted from `pubspec.yaml`.

*What is settled.* A release changes `version:` and nothing else does. The code is a hand-kept integer that only goes up. It is never derived from a commit count, which a shallow clone makes meaningless. Play Console is the authority on which codes have been used, including codes uploaded to testing tracks only.
*Not settled.* `Constants.appVersion` and the menu's version line are separate, stale copies (`docs/DEBT.md`).

## Workflow and delivery

**G-006 — Grid moves onto the cloud-first workflow (2026-10-06).** Decided by the owner in the Grid Claude Project; prepared and executed in a Claude Code session on branch `claude/cloud-workflow-bootstrap`.

*What changed.* The production source — uncommitted changes on the owner's Windows clone since January — was committed first, verbatim. Then came this document set, the committed hooks, the two workflows, `.gitattributes`, the Jekyll exclusions (G-009) and the Antigravity notes under `docs/history/`.
*Why.* The source of the live release existed only on one PC, and so did the only copy of the upload key. Development had to continue from the cloud and the phone, without a local machine.
*What is settled.*
- Chat plans and writes briefs and never writes to the repository. A Claude Code session implements one change on a `claude/…` branch and opens a PR. The owner merges.
- This repository's documents are the only source of project state. The Claude Project's instructions are `docs/claude-project-instructions.md`.
- Configuration: prefix `G-`; no work-order numbers (the PR is the unit); full document tier (there is a lockfile and a multi-step release); gate `flutter analyze`; CI on every PR; no hosting preview (G-010); secrets in Actions secrets plus the owner's password manager; no `.vercelignore` (no Vercel), with Jekyll exclusions in its place (G-009).
- The local clone is retired once a CI-built bundle has been accepted by Play and installed from internal testing (`WORKPLAN.md` Phase 0).

*Paths not taken.* A private repository (G-003). Release builds on the Windows clone: a single machine is the failure this entry exists to remove. A Vercel project: there is no web build to preview.

**G-007 — Release bundles are built by GitHub Actions on manual dispatch from `main`, signed with the upload key from repository secrets (2026-10-06).** `.github/workflows/android-release.yml`.

*What is settled.*
- Nothing builds a release on a push. A release is a deliberate act.
- The workflow refuses to run off `main` or without its three secrets (the key alias is a plain value, not a secret). It writes the keystore outside the checkout, builds, and then **refuses the bundle unless its signing certificate's SHA-1 equals the upload key's** (`OPERATIONS.md` §1). It uploads the bundle as a workflow artifact.
- The owner uploads it in Play Console: internal testing first, production after a device check.
- The keystore is kept in two places: the repository secret, and an item in the owner's password manager. A secret cannot be read back, so the password manager is the only copy outside GitHub.

*Verified (2026-10-06, in the bootstrap session).* A clean clone of this branch built a signed release bundle in a cloud machine (Flutter 3.32.8, JDK 21, a throwaway key): version code 7, name 1.0.3, min 21, target 36. The certificate check was run by hand against that bundle (refused: wrong key) and against production 1.0.3 (6) (admitted).
*Not verified.* The workflow itself, until its first run on GitHub's runner (`WORKPLAN.md` Phase 0).
*Paths not taken.* Uploading to Play automatically through a service account: deferred (§12).

**G-008 — The toolchain is pinned: Flutter 3.32.8 stable (Dart 3.8.1), JDK 21 in CI (2026-10-06).** 3.32.8 is the version production 1.0.3 was built with, read from `.dart_tool/version` on the owner's clone. JDK 21 is the JDK the bootstrap's proof build used. The Android Gradle Plugin, Gradle and Kotlin versions are pinned by `android/settings.gradle.kts` and the Gradle wrapper.

*What is settled.* An upgrade of Flutter, AGP or Gradle is its own PR. It changes `CLAUDE.md` §1, the hook, both workflows and this entry together.

**G-009 — The documents are excluded from the GitHub Pages site (2026-10-06).** `_config.yml` lists them under `exclude`.

*Why.* Pages runs Jekyll over the repository root, and Jekyll processes Markdown files as pages and Liquid inside them. A document containing `{{` or `{%` could fail the Pages build, and that build is what serves `privacy.html` (G-003). This is the counterpart of the guide's `.vercelignore`.
*What is settled.* Every new top-level Markdown document is added to `_config.yml` in the same PR. `privacy.html` and `README.md` stay served.
*Not verified.* The first Pages build after the merge. `OPERATIONS.md` §4 has the check.
*Paths not taken.* `.nojekyll` (serve everything raw): it would drop the rendered `README.md` index page the site has served since 2025.

**G-010 — Merge policy, and what stands in for a preview (2026-10-06).** Grid has no web build, so there is no preview URL. A change a user can see or touch is verified by the owner: build it with the release workflow, upload to the internal testing track, install from Play on the phone. Production follows that check. A change to documents, CI or hooks only is merged on reading the PR and its CI result.

*What is settled.* Internal testing is the device surface, and its version codes count against the code sequence (G-005).

**G-011 — A session merges a PR when the owner tells it to (2026-10-06; supersedes G-010's "the owner merges" and CLAUDE.md constraint 7's wording).** The owner, on PR #1: "you can and should do it! do it". The merge was first refused by the session's permission check, which reads `CLAUDE.md`'s "the owner merges". It went through once the owner switched the session to a mode that asks him to approve the action.

*What is settled.* The owner decides when a PR merges. A session merges when the owner says so in the conversation, after CI is green and the report is read. Without that instruction it pushes, opens the PR and stops. G-010's device-check rule for user-facing changes is unchanged.
*Not settled.* Whether merges should also be approved in advance through the session's permission settings rather than case by case. That is the owner's setting, not a repository rule.

## §9 Superseded index

| ID | Subject | Superseded by |
| --- | --- | --- |
| G-010 (merge clause only) | Who merges | G-011 |

## §10 Assumptions still to validate

- **A-1** GitHub's Ubuntu runner image installs whatever Android platform, build tools, NDK 27.0.12077973 and CMake the build asks for, as the cloud machine did on 2026-10-06. *Validated 2026-10-06:* the first `android-release` run passed every step.
- **A-2** Play accepts a bundle built by the workflow (same upload key, higher code). *Validated 2026-10-06:* bundle 7 was accepted on internal testing once automatic protection was turned off for the release (O-4), and installed on the owner's phone.
- **A-3** The prefix `G-` is unused in the owner's other repositories. The Bauhaus Suite repositories were not checked.

## §11 Open decisions — nothing here is briefed as if decided

- **O-1 README.** `README.md` is Flutter's template text, and it is also the Pages index page. Options: keep it; replace it with a one-line description; or make it a pointer to `SPEC.md` §0 (the guide's default for a public repository). Changing it changes the public site's root page.
- **O-2 Scaffolding folders.** `ios/`, `macos/`, `linux/`, `windows/` and `web/` are unshipped Flutter scaffolding. Keep them, or delete them in one PR?
- **O-4 Android 5.0 support versus Play automatic protection** (found 2026-10-06). Play automatic protection (anti-tamper) requires minimum SDK 24 (Android 7.0); Grid's is 21 (G-004). Google switches the protection on for every new release, so each upload rejects the bundle until it is turned off for that release (OPERATIONS §3 step 5). The choice is between keeping Android 5.0–6.x devices and turning protection off on every release, or raising `minSdk` to 24 to get anti-tamper protection, which ends updates for those devices and reverses G-004. Production builds 6 and 7 shipped without protection.
- **O-3 Privacy wording versus backup.** `privacy.html` says "No automatic uploads or syncing" and lists two permissions. The manifest also declares `INTERNET` and a legacy storage permission, and a backup folder may belong to a cloud drive's document provider. Does the policy text change? It is owner-approved text (CLAUDE.md constraint 5); the Play Data safety form should be checked against the same facts.

## §12 Deliberately deferred

- **D-1 Automatic upload to Play.** The release workflow could push the bundle to the internal testing track through a Google Cloud service account, so a release needs no Play Console upload step. *Reopen when:* the owner wants releases done entirely from the phone. It needs a service account with Play Console access and its key as a fifth repository secret.

## §13 Carried unverified, deliberately

- **U-1** The appearance choice resets on restart (`SPEC.md` §6). Read from code; not seen on a device.
- **U-2** On the owner's clone, `android/app/build.gradle` was modified about nine minutes after the production bundle was built. The bundle's manifest matches the committed file on every value checked (version, SDK levels). Whether that late edit touched anything else could not be determined.
