# SPEC.md — what Grid is now

**Status of this file.** Reconstructed from the code on 2026-10-06 (G-001), from the source of production 1.0.3 (6). Every behaviour below was read from code. **None of it was seen on a device while writing it.** A section that is corrected after a device check says so with the decision number. Constants are read from code, not copied here. No history and no status here: why is `DECISIONS.md`, what is next is `WORKPLAN.md`.

## §0 Definition and principles

**Definition.** Grid is an Android app that shows how a photo feed will look before anything is posted. You import photos into a three-column grid of portrait tiles, put them in order and judge the whole.

**Promise.** Your photos never leave your phone. No account, no sign-up, works offline. All changes are saved as they happen.

**Users.** People who plan a social-media profile feed visually: creators, photographers, designers.

**Devices.** Android phones, Android 7.0 (API 24) and later (G-014). Portrait phone layout. No tablet-specific layout, no iOS build (§11).

**Principles.**
1. Local only (CLAUDE.md constraint 4).
2. The grid is the product. Everything else is in the menu.
3. Nothing is lost: order, profile and photos persist across restarts; a backup can restore them.

**Vocabulary** — use these words and no synonyms:

| Word | Meaning |
| --- | --- |
| **grid** | The three-column arrangement of tiles on the home screen |
| **tile** | One photo's place in the grid, portrait 3:4 |
| **photo** | An imported image: a compressed full image plus a thumbnail, both stored by the app |
| **order** | The sequence of photos in the grid; the user's arrangement |
| **selection** | The set of selected tiles; selection mode starts with the first selected tile |
| **hue map** | The overlay that shows each photo's dominant colour |
| **profile block** | The header above the grid imitating a profile: avatar, username, counts, bio |
| **backup** | A copy of the photos and their order written to a folder the user picks |
| **restore** | Reading a backup back into the app |

## §1 Adding photos

- The **+** button in the top bar opens the system photo picker. Several photos can be picked at once.
- Each photo is compressed to a full image and a thumbnail, processed off the UI thread (`lib/services/image_processor_service.dart`; sizes and quality are constants there). Imports run in batches, with a loading indicator.
- New photos join the grid (position: confirm by reading `lib/providers/photo_provider.dart` `addPhotos`).

## §2 The grid and its order

- Three columns, tile aspect ratio 3:4 (`lib/ui/photo_sliver_grid.dart`).
- **Reorder:** long-press a tile and drag it to a new position; the grid closes up around it. Dragging near the top or bottom edge auto-scrolls (`lib/services/drag_scroll_service.dart`).
- The order is saved automatically and survives restarts. Each photo has a stable UUID; the order is stored in the SQLite database (`photos.db`). An earlier SharedPreferences store is migrated once (`lib/repositories/photo_repository.dart`).
- The **home** icon scrolls to the top of the grid.

## §3 Selecting, deleting, sharing, previewing

- Tap a tile to select or deselect it; long-press also enters selection mode. Selected tiles show a check mark. Tapping an empty area clears the selection.
- **Delete:** with tiles selected, the trash icon in the bottom bar asks for confirmation in a dialog, then removes them.
- **Share:** with exactly one tile selected, the share icon opens the system share sheet.
- **Preview:** double-tap a tile to see it full screen; tap anywhere to close.

## §4 Hue map

- The ink icon in the bottom bar toggles an overlay of each photo's dominant colour, for planning a colour-coordinated layout.
- Dominant colours are computed once and cached (`lib/services/dominant_color_service.dart`).

## §5 Profile block

- Above the grid: avatar, username, post / follower / following counts and a bio. Each field is edited by tapping it; the avatar by tapping it and picking a photo.
- Defaults and storage: `lib/ui/profile_block.dart`. Saved automatically.

## §6 Appearance

- Light and dark appearance, switched in the menu (**Appearance**).
- Whether the choice survives a restart: `lib/app_theme.dart` holds it in memory only, so it is expected to reset to light on restart. Carried unverified (`DECISIONS.md` §13).
- Edge-to-edge display with transparent system bars; the layout keeps clear of the Android navigation bar.

## §7 Backup and restore

- From **Menu → Local Backup**, the user picks a folder through Android's folder picker (Storage Access Framework). The app keeps permission to that folder.
- **Backup** writes the photos and a `manifest.json` describing them and their order into that folder, with progress. The manifest records a SHA-256 checksum for each photo (`lib/repositories/backup_restore_repository.dart`, `lib/repositories/cloud_manifest_repository.dart`).
- **Restore** reads a backup folder back into the app and rebuilds the grid in the saved order.
- The folder can belong to any document provider the phone offers, including a cloud drive's. The app itself only writes to the folder it was given. How that sits with the privacy policy's wording is an open question (`DECISIONS.md` §11).

## §8 Menu

- **Appearance** toggle (§6).
- **Local Backup** (§7).
- **How to Use Grid**: a static guide to the features above (`lib/ui/how_to_use_screen.dart`). Its text is a second description of the app; when behaviour changes, it changes too.
- A **Ko-fi** support link that opens `https://ko-fi.com/tomazdrnovsek` in the browser.
- A version line, `Version <name> (<code>)`, read at runtime from the installed package (`DECISIONS.md` G-012). The Local Backup screen (§7) shows the same line. The name and code are the ones `pubspec.yaml` `version:` gave the build (G-005).

## §9 Privacy and permissions

- Permissions (`android/app/src/main/AndroidManifest.xml`): `READ_MEDIA_IMAGES`, `READ_MEDIA_VISUAL_USER_SELECTED`, `READ_EXTERNAL_STORAGE` up to API 32, and `INTERNET` (used by the support link).
- The policy text is `privacy.html` (CLAUDE.md constraint 5). Where it and this section disagree, see `docs/DEBT.md`.
- No analytics, advertising, tracking or accounts (§0).

## §10 Open

Open questions live in `DECISIONS.md` §11, one home. Nothing there is resolved by implementing it.

## §11 Out of scope

These are permanently excluded unless a new decision reopens them:
- Posting to, or connecting to, any social network.
- Accounts, sync between devices through a server, or any server.
- Analytics, advertising, tracking.
- An iOS release. The `ios/`, `macos/`, `linux/`, `windows/` and `web/` folders are Flutter's scaffolding and are not shipped (`DECISIONS.md` §11 asks whether to keep them).
