#!/bin/bash
# Install the Android SDK pieces a debug compile needs, in a cloud session.
# Not run by any hook: only a session that needs `flutter build apk --debug`
# runs it, once per machine (CLAUDE.md §3). Release builds happen in the
# android-release workflow, never here (CLAUDE.md constraint 8).
#
# Also installs a Gradle init script that sends Maven Central requests to
# Google's public mirror of it, because Maven Central answers 429 to the
# cloud sandbox's shared egress (CLAUDE.md §8, observed 2026-10-06). That
# includes plugin resolution, where the Gradle Plugin Portal redirects to
# Maven Central. The init script lives in ~/.gradle, outside the repository.
set -euo pipefail

SDK="${ANDROID_HOME:-$HOME/android-sdk}"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-13114758_latest.zip"

if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "android-sdk: installing command-line tools into $SDK"
  mkdir -p "$SDK/cmdline-tools"
  tmp="$(mktemp -d)"
  curl -sSL -o "$tmp/clt.zip" "https://dl.google.com/android/repository/$CMDLINE_TOOLS_ZIP"
  unzip -q "$tmp/clt.zip" -d "$tmp"
  rm -rf "$SDK/cmdline-tools/latest"
  mv "$tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
  rm -rf "$tmp"
fi

yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" --licenses >/dev/null 2>&1 || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" \
  "platform-tools" "platforms;android-36" "build-tools;36.0.0" >/dev/null

mkdir -p "$HOME/.gradle/init.d"
cat > "$HOME/.gradle/init.d/central-mirror.gradle" <<'EOF'
// Written by docs/tools/android-sdk.sh. Maven Central answers 429 to the cloud
// sandbox's shared egress; send its traffic to Google's public mirror of it.
def MIRROR = 'https://maven-central.storage-download.googleapis.com/maven2/'
def rewrite = { repos ->
  repos.all { r ->
    if (r instanceof MavenArtifactRepository && r.url.toString().startsWith('https://repo.maven.apache.org/maven2')) {
      r.url = MIRROR
    }
  }
}
// The Gradle Plugin Portal redirects whatever it does not host to Maven Central,
// which the rewrite above cannot see. Plugin resolution asks the mirror first; a
// file the mirror lacks is a 404 there, and Gradle moves on to the next repository.
// An empty list means Gradle's implicit default, the portal, so it is kept.
def mirrorFirst = { repos ->
  if (repos.isEmpty()) {
    repos.maven { url = MIRROR }
    repos.gradlePluginPortal()
  } else {
    def m = repos.maven { url = MIRROR }
    repos.remove(m)
    repos.addFirst(m)
  }
}
beforeSettings { s -> rewrite(s.pluginManagement.repositories); rewrite(s.buildscript.repositories) }
settingsEvaluated { s ->
  rewrite(s.pluginManagement.repositories); rewrite(s.dependencyResolutionManagement.repositories)
  mirrorFirst(s.pluginManagement.repositories)
}
allprojects { rewrite(buildscript.repositories); rewrite(repositories) }
EOF

flutter config --android-sdk "$SDK" >/dev/null
echo "android-sdk: ready at $SDK. Next: flutter build apk --debug"
