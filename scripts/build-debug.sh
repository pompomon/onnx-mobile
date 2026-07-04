#!/usr/bin/env bash
# scripts/build-debug.sh
#
# Build a debug APK using the Gradle wrapper.
# Intended to be run inside a Codespace or any machine with the Android SDK
# correctly configured (see scripts/bootstrap-android-sdk.sh).
#
# Usage:
#   bash scripts/build-debug.sh [extra gradlew flags]
#
# Examples:
#   bash scripts/build-debug.sh
#   bash scripts/build-debug.sh --info
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# ── Validate Gradle wrapper ────────────────────────────────────────────────────
if [[ ! -f "./gradlew" ]]; then
  echo "ERROR: Gradle wrapper (./gradlew) not found in ${REPO_ROOT}." >&2
  echo "       Generate it with: gradle wrapper --gradle-version <version>" >&2
  exit 1
fi

chmod +x ./gradlew

echo "==> Building debug APK"
echo "    Repo root : ${REPO_ROOT}"
echo "    Gradle    : $(./gradlew --version | grep -i 'Gradle ' | head -1 || true)"
echo ""

./gradlew assembleDebug "$@"

echo ""
echo "==> Debug APK build complete."
APK_OUTPUT="$(find ./app/build/outputs/apk/debug -name '*.apk' 2>/dev/null | head -5)"
echo "    Output: ${APK_OUTPUT:-(no APK found — check build output above)}"
