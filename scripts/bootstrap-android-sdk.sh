#!/usr/bin/env bash
# scripts/bootstrap-android-sdk.sh
#
# Standalone script to install/update Android SDK packages.
# Can be run inside or outside a Codespace as long as:
#   - ANDROID_SDK_ROOT is set and sdkmanager is on PATH
#   - An internet connection is available
#
# Usage:
#   bash scripts/bootstrap-android-sdk.sh
set -euo pipefail

# ── Validate prerequisites ────────────────────────────────────────────────────
if [[ -z "${ANDROID_SDK_ROOT:-}" ]]; then
  echo "ERROR: ANDROID_SDK_ROOT is not set." >&2
  echo "       Export it before running this script, e.g.:" >&2
  echo "       export ANDROID_SDK_ROOT=/opt/android-sdk" >&2
  exit 1
fi

if ! command -v sdkmanager &>/dev/null; then
  echo "ERROR: sdkmanager not found on PATH." >&2
  echo "       Ensure \${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin is in PATH." >&2
  exit 1
fi

echo "==> Android SDK root : ${ANDROID_SDK_ROOT}"
echo "==> sdkmanager       : $(command -v sdkmanager)"
echo "==> sdkmanager version:"
sdkmanager --version

# ── Accept licences ───────────────────────────────────────────────────────────
echo ""
echo "==> Accepting SDK licences"
yes | sdkmanager --licenses > /dev/null 2>&1 || true

# ── Install packages ──────────────────────────────────────────────────────────
echo ""
echo "==> Installing SDK packages"
sdkmanager \
  "platform-tools" \
  "platforms;android-34" \
  "build-tools;34.0.0" \
  "cmdline-tools;latest"

echo ""
echo "==> Installed packages:"
sdkmanager --list_installed 2>/dev/null || sdkmanager --list | grep -A1 "Installed" || true

echo ""
echo "==> Bootstrap complete."
