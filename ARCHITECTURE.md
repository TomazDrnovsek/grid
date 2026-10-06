# ARCHITECTURE.md — how Grid is built

Reconstructed from the code on 2026-10-06 (G-001). The narrative of how it got here is `DECISIONS.md`'s; this file describes what is.

## §1 Operating constraints

The hard constraints are `CLAUDE.md` §2. Their consequences for the architecture:
- No backend, no network calls by the app. The only external request is the browser opening a link.
- All state is on the device: SQLite, SharedPreferences, the app's documents directory, and a user-chosen backup folder.
- Zero running cost. GitHub (public repository: Actions minutes and Pages are free) and the Google Play developer account are the only services.

## §2 Stack as implemented — and the file that proves each row

| Layer | What | Proved by |
| --- | --- | --- |
| Framework | Flutter 3.32.8 stable, Dart 3.8.1 (G-008) | `pubspec.yaml` `environment`, `.github/workflows/*.yml` |
| State | Riverpod 2 with code generation (`@riverpod`) | `lib/providers/photo_provider.dart`, `lib/providers/backup_provider.dart` |
| Models | freezed + json_serializable, generated files committed | `lib/models/*.dart`, `lib/models/*.freezed.dart`, `*.g.dart` |
| Services | A hand-rolled service locator holding the database, thumbnail, image-cache, performance and scroll services | `lib/core/service_locator.dart`, `lib/main.dart` |
| Database | sqflite, file `photos.db` | `lib/services/photo_database.dart` |
| Preferences | shared_preferences: profile, migration flag, backup folder, last backup date, device id, colour cache | `git grep "static const String _[a-zA-Z]*[Kk]ey" lib` |
| Images | image_picker, flutter_image_compress, palette_generator (dominant colour), flutter_svg (icons) | `lib/services/image_processor_service.dart`, `lib/services/dominant_color_service.dart` |
| Native | Kotlin `MainActivity` exposing the Storage Access Framework over `MethodChannel` `com.grid/saf` | `android/app/src/main/kotlin/si/tomazdrnovsek/grid/MainActivity.kt`, `lib/repositories/saf_storage_provider.dart` |
| Sharing, links | share_plus, url_launcher | `pubspec.yaml` |
| Version at runtime | package_info_plus 8.x: the installed package's version name and code (G-012) | `lib/ui/menu_screen.dart` |
| Android build | AGP 8.7.3, Kotlin 2.1.0, Gradle 8.12, NDK 27.0.12077973, compile/target 36, min 21 (G-004) | `android/settings.gradle.kts`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle` |
| Release shrink | R8 minify and resource shrinking on, Android's default optimize rules | `android/app/build.gradle` `buildTypes.release` |

## §3 Data model

- **Photos.** Each imported photo becomes a compressed full image and a thumbnail, written into the app's documents directory (`lib/file_utils.dart`). A row in `photos.db` gives it a stable UUID, its file paths and its position. The order in the grid is the order in the database (`lib/repositories/photo_repository.dart`).
- **Legacy migration.** Versions before the database kept paths in SharedPreferences (`grid_image_paths`, `header_username`). `PhotoRepository` migrates them once and sets `database_migration_complete`. The legacy keys are addresses: an old install can still be carrying them.
- **Profile.** One JSON object under `profile_data` (`lib/ui/profile_block.dart`).
- **Dominant colours.** Cached under `dominant_colors_cache_v2`. The `_v2` is part of the address.
- **Backup.** A folder chosen through Storage Access Framework, URI and name in `cloud_folder_uri` / `cloud_folder_name`. Inside it: the photo files and `manifest.json` (written via `manifest.json.tmp`), whose structure is `BackupManifest` in `lib/models/backup_models.dart` (`Constants.manifestVersion`). Its `appVersion` field holds the installed version name (G-012). Each photo's SHA-256 is recorded in the manifest (`lib/services/backup_hasher.dart`).

## §4 Platform integration

- Edge-to-edge with transparent system bars (`lib/main.dart`, `MainActivity.onCreate`). Content keeps clear of the navigation bar (last commit before G-006).
- Permissions: `SPEC.md` §9.
- `MainActivity` implements, on a lifecycle-bound coroutine scope, the channel methods `pickDirectory`, `releaseUri`, `exists`, `list`, `read`, `write`, `beginWrite` / `writeChunk` / `endWrite` / `abortWrite` (streamed writes in 64 KB chunks), `copyToLocalFile`, `mkdirs`, `rename`, `delete` and `getPersistedUris`. Read the live list from the `when (call.method)` block; every name there is an address (`CLAUDE.md` §6).

## §5 Packaging and signing

- `android/app/build.gradle` reads the signing config from `android/key.properties`: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. If Android Studio injects signing properties, those win. `storeFile` may be absolute; CI writes the keystore outside the checkout and points to it (G-007).
- With no `key.properties`, a release build fails at `:app:signReleaseBundle` (`CLAUDE.md` §8).
- The version name and code come from `pubspec.yaml` through `local.properties` (G-005).

## §6 Quality gate

- **Gate:** `flutter analyze`, using `flutter_lints` (`analysis_options.yaml`), then `flutter test` (G-013).
- **CI:** `.github/workflows/quality.yml` runs `flutter pub get`, `flutter analyze` and `flutter test` on every pull request and every push to `main`. It has read-only permissions and a 15-minute limit, and newer runs cancel older ones on the same ref.
- **Tests:** one smoke test, `test/widget_test.dart`. It pumps `GridApp` in a `ProviderScope` and checks that the splash screen builds without an exception. It does not run `main()`'s service-locator setup and stops before the grid, whose database and plugins a widget test does not have.
- **Release check:** the signing-certificate comparison inside `android-release.yml` (G-007). Its comparison was run by hand: it refused a throwaway-signed bundle and admitted the production one. The workflow has not run yet (`DECISIONS.md` G-007).

## §7 Release checklist

The procedure is `OPERATIONS.md` §3. Before dispatching a release, the PR that bumps `version:` has merged. The gate is green on `main`. Anything user-facing in it has been seen on a phone from internal testing, or is about to be (G-010).

## §8 Git and delivery

- `main` is what releases are built from. Every change is a branch (`claude/…` for cloud sessions) and a PR; the owner merges.
- LF line endings everywhere (`.gitattributes`).
- GitHub Pages serves the repository root of `main` with Jekyll: `privacy.html` and the `README.md` index. The documents are excluded (`_config.yml`, G-009).
- Nothing deploys on merge except Pages. A release is a manual workflow run followed by a manual Play Console upload.
