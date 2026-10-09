# OPERATIONS.md — how Grid is run and released

## §1 Identifiers

Secret **values** never appear in this repository. A row existing does not mean the secret holds a value; check it in GitHub's settings page.

| What | Identifier |
| --- | --- |
| Repository | `TomazDrnovsek/grid` (public, G-003); releases built from `main` |
| Application id | `si.tomazdrnovsek.grid` |
| Play Console | developer account `8350335014670061178`, app `4972888801958749616` |
| Privacy policy URL (registered in Play) | `https://tomazdrnovsek.github.io/grid/privacy.html` |
| Upload key | alias `upload`, PKCS12; certificate SHA-1 `CA:5B:CB:6F:E5:80:2F:07:9E:59:E5:59:70:3D:5D:5D:71:01:4B:FD`; SHA-256 `CC:8D:AD:A6:5B:E8:27:ED:CB:90:54:6A:D5:1D:66:57:0C:6B:F8:71:84:46:78:5D:CB:81:80:F5:70:B8:4C:23` |
| App signing key | held by Google (Play App Signing). Its certificate is in Play Console → Test and release → App integrity |
| Actions secret | `ANDROID_KEYSTORE_BASE64` — the upload keystore file as plain base64, made with the PowerShell line below |
| Actions secret | `ANDROID_KEYSTORE_PASSWORD` |
| Actions secret | `ANDROID_KEY_PASSWORD` |
| Key alias | `upload` — a plain value in `android-release.yml`, deliberately not a secret: GitHub masks a secret's value everywhere in a run's log, and "upload" is a common word |
| Owner's copy of the key | password manager item "Grid upload key": the keystore file, both passwords, the alias |

Making the keystore secret's value, on the Windows PC that holds the file. This copies it to the clipboard; paste it straight into the secret. Don't use `certutil -encode`, which adds header lines the workflow refuses:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("<path to>\upload-keystore.jks")) | Set-Clipboard
```

The passwords go into `key.properties`, a Java properties file. A password containing `\` or a non-ASCII character would be read differently there, and signing would fail with "keystore password was incorrect". The current passwords already worked in exactly this file format on the owner's clone.

The certificate fingerprints are public facts about a public certificate. They are what the release check compares against (G-007).

## §2 Delivery of a change

Branch → `flutter analyze` and `flutter test` → PR → CI (`quality.yml`) green, or the failing step read → owner merges (G-010). A merge deploys nothing except the GitHub Pages site (§4). A merged change reaches users only through a release (§3).

## §3 Release

1. **Bump the version** in a PR: `pubspec.yaml` `version: <name>+<code>`. The code must be higher than every code in Play Console → Test and release → Latest releases and bundles, testing tracks included. Merge it.
2. **Build.** GitHub → Actions → **Android release** → Run workflow (branch `main`). On the phone: GitHub app → the repository → Actions → Android release → Run workflow. It takes about 10–15 minutes.
3. **Read the run.** A green run ends with a summary naming the version name, code and certificate SHA-1. A red run: open the failing step. "Secrets missing", "not main" and "certificate mismatch" are deliberate refusals with their reason printed.
4. **Download the bundle.** On the run page → Artifacts → `grid-<name>-<code>`: a zip holding `app-release.aab`. On a phone, open the run in a browser (the GitHub app may not offer artifact downloads) and unzip in the Files app.
5. **Upload to internal testing.** Play Console → Test and release → Testing → Internal testing → Create new release. Leave Play automatic protection on: it requires a minimum SDK of 24, which Grid has from 1.0.4 (9) (G-014). Upload `app-release.aab` → release notes → Save → Review → Roll out.
   - **Release notes** come from the session that built the release, with the bundle, every time (owner, 2026-10-06: "Always give me release notes too"). They are ready to paste into Play's release notes box: inside Play's `<en-US>` … `</en-US>` language tags, at most 500 characters within the tags, written for users. They describe what changed since the last production release and never name the build code (G-017).
   - If an upload is rejected, Play has usually **already stored that version code**: uploading the same file again fails with "Version code N has already been used". Remove the failed row (✕) and use **Add from library** to pick the stored bundle instead of building a new one (observed 2026-10-06).
6. **Device check.** Install the update from Play on the phone, as an internal tester. Check what the release changed, and that existing photos, order and profile survived the update.
7. **Promote.** On the internal-testing release → Promote release → Production → review → roll out. Or create a production release from the same bundle in the App bundle explorer.
8. **Record.** Promoting needs no repository change. If something went wrong, `docs/incidents.md` gets an entry.

Upload is manual by decision (G-007). Nothing uploads to Play automatically (G-022).

## §4 GitHub Pages

- Source: `main`, repository root, Jekyll. It serves `privacy.html` and renders `README.md` as the index. The documents are excluded by `_config.yml` (G-009).
- After any PR that touches `_config.yml`, `privacy.html` or a root Markdown file, check two things after the merge. First, the run named "pages build and deployment" under Actions is green. Second, `https://tomazdrnovsek.github.io/grid/privacy.html` loads. A failed Pages build leaves the last good site up but stops updates.

## §5 Runbooks

**Lost upload key** (the PC died and the password-manager copy is gone): Play Console → Test and release → App integrity → Upload key certificate → **Request upload key reset**. Generate a new key as Google instructs; once approved, replace the three Actions secrets and update the fingerprints in §1 and in `android-release.yml` in one PR. Users are unaffected, because Google holds the app signing key (G-002). Publishing pauses until the reset is approved.

**Leaked upload key** (a secret value appeared anywhere public): the same reset, at once. A leaked key alone cannot reach users, but it can be used to upload as you.

**Rotating the secrets:** GitHub → Settings → Secrets and variables → Actions → each secret → Update. The values come from the password-manager item. Then run a release build to prove them; uploading it is optional.

**Workflow fails on SDK setup:** read the failing step. The runner's preinstalled Android SDK is used deliberately, with no SDK-install action. A missing platform or NDK is downloaded by the Android Gradle Plugin itself (`DECISIONS.md` §10 A-1).

**Play target-API deadline:** Google raises the required target API every August. The change is `compileSdk`/`targetSdk` in `android/app/build.gradle`, plus the matching platform. Verify the requirement on Google's page, not from memory.

## §6 Verification checklist after a production release

- The production row in Play Console shows the new version, "Available on Google Play", at the rollout you chose.
- The phone updates from Play, and existing photos, order and profile are intact.
- Play Console → Monitor and improve → Android vitals shows no new crash cluster in the following days.
