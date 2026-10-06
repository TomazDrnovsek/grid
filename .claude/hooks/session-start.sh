#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: install the pinned Flutter
# SDK (G-008) once, put it on PATH, and fetch the lockfile's packages.
# Only in a remote session: on a local clone the person owns their SDK.
# Synchronous on purpose, so nothing runs the gate against a half-installed
# tree. Idempotent.
set -euo pipefail
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then exit 0; fi

FLUTTER_VERSION="3.32.8"            # G-008 — change only together with the workflows
FLUTTER_HOME="${HOME}/flutter-${FLUTTER_VERSION}"
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"

if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  echo "session-start: installing Flutter ${FLUTTER_VERSION}"
  rm -rf "${FLUTTER_HOME}"
  git clone --quiet --depth 1 --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git "${FLUTTER_HOME}"
fi

# Make `flutter` and `dart` reachable from every later shell in the session.
if [ -w /usr/local/bin ]; then
  ln -sf "${FLUTTER_HOME}/bin/flutter" /usr/local/bin/flutter
  ln -sf "${FLUTTER_HOME}/bin/dart" /usr/local/bin/dart
fi
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"${FLUTTER_HOME}/bin:\$PATH\"" >> "${CLAUDE_ENV_FILE}"
fi
export PATH="${FLUTTER_HOME}/bin:${PATH}"

flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version 2>/dev/null | head -1    # first run downloads the Dart SDK

if [ -f .dart_tool/package_config.json ] && [ .dart_tool/package_config.json -nt pubspec.lock ]; then
  echo "session-start: packages are current, nothing to fetch"
  exit 0
fi
echo "session-start: flutter pub get"
flutter pub get
