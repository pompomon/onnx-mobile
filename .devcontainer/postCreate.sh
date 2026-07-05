#!/usr/bin/env bash
# .devcontainer/postCreate.sh
#
# Runs automatically after the dev container is created (postCreateCommand).
# Purpose:
#   1. Accept Android SDK licences
#   2. Ensure required SDK packages are installed / up-to-date
#   3. Verify the Gradle wrapper resolves correctly
#   4. Optionally warm the Gradle build cache
#
# This script is idempotent — safe to run multiple times.
set -euo pipefail

echo "==> [postCreate] Starting Android development environment bootstrap"

# ── Validate SDK is reachable ─────────────────────────────────────────────────
if ! command -v sdkmanager &>/dev/null; then
  echo "ERROR: sdkmanager not found. Check that ANDROID_SDK_ROOT is set correctly." >&2
  exit 1
fi

echo "==> [postCreate] Android SDK root: ${ANDROID_SDK_ROOT:-(not set)}"
echo "==> [postCreate] sdkmanager: $(command -v sdkmanager)"

# ── Accept all licences (non-interactive) ─────────────────────────────────────
echo "==> [postCreate] Accepting Android SDK licences"
yes | sdkmanager --licenses > /dev/null 2>&1 || true   # tolerate partial acceptance

# ── Install / update required SDK packages ────────────────────────────────────
echo "==> [postCreate] Installing/updating SDK packages"
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "cmdline-tools;latest"

# ── Gradle wrapper check ─────────────────────────────────────────────────────
# Derive the repository root deterministically from this script's location
# (.devcontainer/postCreate.sh → repo root is one level up), falling back to the
# current working directory if that can't be resolved. Avoids hard-coding a path
# like /workspace that differs between local devcontainers and Codespaces.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "${SCRIPT_DIR}/.." 2>/dev/null && pwd || pwd)"
cd "${WORKSPACE}"

if [[ -f "./gradlew" ]]; then
  echo "==> [postCreate] Gradle wrapper found — verifying"
  chmod +x ./gradlew
  ./gradlew --version
else
  echo "WARNING: gradlew not found in ${WORKSPACE}. Add a Gradle wrapper before building." >&2
fi

# ── Optional: warm Gradle cache ───────────────────────────────────────────────
# Uncomment the next block to pre-download dependencies on container creation.
# This increases creation time but speeds up the first real build significantly.
#
# if [[ -f "./gradlew" ]]; then
#   echo "==> [postCreate] Warming Gradle dependency cache"
#   ./gradlew :app:assembleDebug -x test --no-daemon 2>&1 | tail -20 || true
# fi

echo "==> [postCreate] Bootstrap complete. Happy building!"
