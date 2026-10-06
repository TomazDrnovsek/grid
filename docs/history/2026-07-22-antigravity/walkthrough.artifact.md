# Walkthrough - Prepared App for Google Play Release

I have updated the application configuration to prepare for a new release on the Google Play Store.

## Changes Made

### 1. Updated App Version
I updated the version in [pubspec.yaml](file:///C:/Users/tomaz/Documents/grid/pubspec.yaml) to `1.0.3+6`.
- **Version Name**: `1.0.3`
- **Version Code**: `6` (increments from the previous `5`)

### 2. Automated Android Versioning
I modified [android/app/build.gradle](file:///C:/Users/tomaz/Documents/grid/android/app/build.gradle) to automatically read the version from `pubspec.yaml`. This ensures you only need to change the version in one place in the future.

```diff
-        versionCode = 3
-        versionName = "1.0.1"
+        versionCode flutterVersionCode.toInteger()
+        versionName flutterVersionName
```

### 3. Build Verification
I ran `flutter pub get` to synchronize the dependencies and update local build properties.

## Step-by-Step Guide to Build and Publish

1.  **Open Terminal**: Open the terminal in Android Studio.
2.  **Generate App Bundle**: Run the following command:
    ```bash
    flutter build appbundle --release
    ```
    *This will create the `.aab` file at `build/app/outputs/bundle/release/app-release.aab`.*
3.  **Locate the Bundle**: Find the generated file in your project directory.
4.  **Upload to Play Console**:
    - Go to the [Google Play Console](https://play.google.com/console/).
    - Select your app.
    - Go to **Production** -> **Create new release**.
    - Upload the `app-release.aab` file.
    - Review and roll out.

> [!IMPORTANT]
> **Keystore**: I verified that your `key.properties` exists and points to `upload-keystore.jks`. Ensure this keystore file is present in the `android/app` folder (or where `key.properties` points) when running the build.

> [!TIP]
> **API 36**: The app is currently targeting API 36. If you encounter build issues, ensure you have the "Android 16 (VanillaIceCream)" SDK platform installed in your SDK Manager.
