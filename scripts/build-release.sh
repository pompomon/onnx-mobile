#!/usr/bin/env bash
# scripts/build-release.sh
#
# Build a release APK using the Gradle wrapper.
#
# Signing configuration:
#   Release builds require a keystore. Supply credentials via environment
#   variables (never commit them to source control):
#
#     KEYSTORE_PATH     – path to the .jks / .keystore file
#     KEYSTORE_PASSWORD – keystore password
#     KEY_ALIAS         – key alias within the keystore
#     KEY_PASSWORD      – key password
#
#   In Codespaces, set these as Codespaces secrets (Settings → Secrets).
#
# Usage:
#   bash scripts/build-release.sh [extra gradlew flags]
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

# ── Signing check ─────────────────────────────────────────────────────────────
if [[ -z "${KEYSTORE_PATH:-}" ]] || [[ -z "${KEYSTORE_PASSWORD:-}" ]] || \
   [[ -z "${KEY_ALIAS:-}" ]] || [[ -z "${KEY_PASSWORD:-}" ]]; then
  echo "WARNING: One or more signing env vars are not set."
  echo "         KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD"
  echo "         The build will proceed but may fail if signing is configured"
  echo "         in build.gradle without fallback to debug signing."
fi

echo "==> Building release APK"
echo "    Repo root : ${REPO_ROOT}"
echo "    Gradle    : $(./gradlew --version | grep -i 'Gradle ' | head -1 || true)"
echo ""

./gradlew assembleRelease "$@"

echo ""
echo "==> Release APK build complete."
APK_OUTPUT="$(find ./app/build/outputs/apk/release -name '*.apk' 2>/dev/null | head -5)"
echo "    Output: ${APK_OUTPUT:-(no APK found — check build output above)}"
