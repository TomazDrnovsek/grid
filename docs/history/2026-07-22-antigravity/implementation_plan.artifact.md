# Implementation Plan - Fix API 36 Device Support and Release Errors

The goal is to target Android 16 (API 36) while maintaining maximum device compatibility and resolving Play Console errors.

## User Review Required

> [!IMPORTANT]
> **Device Support**: To recover the 21,000+ lost devices, I am going to explicitly set `minSdk` to `21` (Android 5.0). Using the Flutter default `minSdkVersion` can sometimes jump to higher versions when the `targetSdk` is very high.

> [!WARNING]
> **Play Console Error**: The "You cannot remove all production APKs" error is a UI issue. You must ensure you don't delete the draft or the old bundle until the *new* bundle is fully uploaded and visible in the same release.

## Proposed Changes

### Build Configuration

#### [MODIFY] [build.gradle](file:///C:/Users/tomaz/Documents/grid/android/app/build.gradle)
- Explicitly set `minSdk = 21` instead of `flutter.minSdkVersion`.
- Ensure `targetSdk` and `compileSdk` remain at `36`.
- Add `abiFilters` to explicitly include 32-bit support, which is sometimes dropped by default in newer Gradle/NDK versions when targeting very high APIs.

## Verification Plan

### Manual Verification
- Run `flutter build appbundle --release`.
- Verify the output log for the version code `6` and version name `1.0.3`.
- After uploading to Play Store, the "device support" warning should either disappear or show a much smaller number of unsupported devices (only those truly incompatible with Android 16 features).
