# Makefile for onnx-mobile
#
# Convenience targets that wrap the Gradle build system.
# Primary build environment: GitHub Codespaces (see docs/codespaces-android.md)
#
# Prerequisites: complete Gradle wrapper must exist in the repo root.
#
# Usage:
#   make apk-debug      – build a debug APK
#   make apk-release    – build a release APK (requires signing env vars)
#   make check          – run lint + unit tests
#   make clean          – remove all build outputs
#   make bootstrap      – install/update Android SDK packages

.PHONY: apk-debug apk-release check clean bootstrap

# ── Helpers ───────────────────────────────────────────────────────────────────
GRADLEW := ./gradlew

define require-gradlew
	@if [ ! -f "$(GRADLEW)" ] || [ ! -f "gradle/wrapper/gradle-wrapper.properties" ] || [ ! -f "gradle/wrapper/gradle-wrapper.jar" ]; then \
	  echo "ERROR: Complete Gradle wrapper not found."; \
	  echo "       Required: $(GRADLEW), gradle/wrapper/gradle-wrapper.properties, gradle/wrapper/gradle-wrapper.jar"; \
	  echo "       Generate it with: gradle wrapper --gradle-version <version>"; \
	  exit 1; \
	fi
	@chmod +x $(GRADLEW)
endef

# ── Targets ───────────────────────────────────────────────────────────────────

## Build a debug APK
apk-debug:
	$(call require-gradlew)
	$(GRADLEW) assembleDebug

## Build a release APK (KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD must be set)
apk-release:
	$(call require-gradlew)
	$(GRADLEW) assembleRelease

## Run lint and unit tests
check:
	$(call require-gradlew)
	$(GRADLEW) lint test

## Remove all build artifacts
clean:
	$(call require-gradlew)
	$(GRADLEW) clean

## Install/update Android SDK packages
bootstrap:
	bash scripts/bootstrap-android-sdk.sh
