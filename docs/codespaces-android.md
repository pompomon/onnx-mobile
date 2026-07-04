# Codespaces-First Android Build Workflow

This document is the canonical reference for building **onnx-mobile** APKs
inside GitHub Codespaces, keeping GitHub Actions usage to a minimum.

---

## Table of Contents

1. [Why Codespaces?](#why-codespaces)
2. [Machine Size Recommendation](#machine-size-recommendation)
3. [Opening a Codespace](#opening-a-codespace)
4. [First Build](#first-build)
5. [Daily Workflow](#daily-workflow)
6. [Release Signing](#release-signing)
7. [Codespaces Secrets Setup](#codespaces-secrets-setup)
8. [Performance Tips](#performance-tips)
9. [GitHub Actions (Minimal Strategy)](#github-actions-minimal-strategy)
10. [Troubleshooting](#troubleshooting)

---

## Why Codespaces?

Android Gradle builds are resource-intensive and have large toolchain
dependencies (JDK 17, Android SDK, Gradle, ONNX libraries). GitHub Actions
minutes are limited and runner setup is slow for heavy SDKs.

With Codespaces:

- The dev container pre-installs **JDK 17** and the **Android SDK** at image
  build time.
- Gradle caches are persisted in a named volume across Codespace rebuilds.
- You get a full VS Code IDE with Kotlin/Java/Gradle extensions.
- Signing credentials live as **Codespaces secrets**, never in source control.

---

## Machine Size Recommendation

| Use case | CPUs | RAM | Storage |
|---|---|---|---|
| Minimum (lint/check only) | 4-core | 8 GB | 32 GB |
| **Recommended (full APK build)** | **8-core** | **16 GB** | **32 GB** |
| Heavy (multiple flavors / parallel) | 16-core | 32 GB | 64 GB |

> **Note:** The `devcontainer.json` includes a `hostRequirements` hint for
> 8-core / 16 GB. Codespaces will prompt you to confirm or upgrade.

---

## Opening a Codespace

1. Go to the repository on GitHub.
2. Click **Code → Codespaces → Create codespace on main** (or your branch).
3. Choose a machine size ≥ 8-core / 16 GB when prompted.
4. Wait for container build + `postCreate.sh` to finish (~3–5 min on first run;
   much faster on subsequent starts thanks to Gradle cache volume).

---

## First Build

Once the Codespace is ready, open the integrated terminal and run:

```bash
# Verify toolchain
java -version          # should print openjdk 17
sdkmanager --version   # should print a version number

# Build a debug APK
make apk-debug
# or directly:
bash scripts/build-debug.sh
```

The first Gradle execution downloads all dependencies and may take several
minutes. Subsequent builds are incremental and much faster.

---

## Daily Workflow

```bash
# Full debug build
make apk-debug

# Full release build (requires signing secrets — see below)
make apk-release

# Lint + unit tests only
make check

# Clean build outputs
make clean

# Re-run SDK bootstrap (after adding new SDK packages)
make bootstrap
```

Gradle wrapper flags can be passed directly to the scripts:

```bash
bash scripts/build-debug.sh --info        # verbose Gradle output
bash scripts/build-debug.sh --scan        # Gradle build scan
```

---

## Release Signing

Release APKs must be signed. **Never commit your keystore or passwords.**

### Prepare your keystore (once)

```bash
# Generate a keystore (if you don't have one already)
keytool -genkey -v \
  -keystore release.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias onnx-mobile
```

Then base64-encode it for storage as a secret:

```bash
base64 -w 0 release.jks > release.jks.b64
cat release.jks.b64   # copy this value
```

### Decode the keystore in your Codespace session

Add to your `~/.bashrc` or run manually each session:

```bash
mkdir -p ~/.android/keystores
echo "${KEYSTORE_B64}" | base64 -d > ~/.android/keystores/release.jks
```

Then set signing env vars:

```bash
export KEYSTORE_PATH=~/.android/keystores/release.jks
export KEYSTORE_PASSWORD=<your-store-password>
export KEY_ALIAS=onnx-mobile
export KEY_PASSWORD=<your-key-password>
```

Finally:

```bash
make apk-release
```

---

## Codespaces Secrets Setup

Store sensitive values as **Codespaces secrets** so they are automatically
injected as environment variables:

1. Go to **github.com/settings/codespaces** (personal secrets) or
   **Repository → Settings → Secrets and variables → Codespaces** (repo-scoped).
2. Add the following secrets:

   | Secret name | Value |
   |---|---|
   | `KEYSTORE_B64` | Base64-encoded `.jks` file contents |
   | `KEYSTORE_PASSWORD` | Keystore password |
   | `KEY_ALIAS` | Key alias |
   | `KEY_PASSWORD` | Key password |

3. These are available as environment variables when your Codespace starts.

---

## Performance Tips

Add (or verify) the following in your project's `gradle.properties`:

```properties
# Enable build cache for incremental rebuilds
org.gradle.caching=true

# Parallel project execution
org.gradle.parallel=true

# Give the JVM enough heap (adjust to available RAM)
org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8

# Configure on demand (safe for most Android projects)
org.gradle.configureondemand=true
```

The Gradle cache volume (`pompomon-onnx-mobile-gradle-cache`) defined in
`devcontainer.json` persists across Codespace rebuilds, so downloaded
dependencies are reused.

---

## GitHub Actions (Minimal Strategy)

Full APK builds live in Codespaces. GitHub Actions is limited to:

| Workflow | Trigger | What it does |
|---|---|---|
| `android-check.yml` | PR / push to `main` | Runs `./gradlew lint` (lightweight validation) |

This provides a quick safety net without spending significant Actions minutes
on full builds.

If you ever need to publish a release from Actions (e.g. on a tag), configure
a separate, manually-triggered workflow that rebuilds and signs the APK. Store
the keystore and credentials as **Actions secrets** (separate from Codespaces
secrets).

---

## Troubleshooting

### `sdkmanager: command not found`

Verify that `ANDROID_SDK_ROOT` is set and that `cmdline-tools/latest/bin` is
on your `PATH`:

```bash
echo $ANDROID_SDK_ROOT
ls $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
```

### Licence errors during build

```bash
yes | sdkmanager --licenses
```

### `gradlew: No such file or directory`

The Gradle wrapper has not been committed to the repo. Add it once:

```bash
gradle wrapper --gradle-version 8.7
git add gradlew gradlew.bat gradle/
git commit -m "chore: add Gradle wrapper"
```

### Out-of-disk space

Android SDK + Gradle caches are large. On Codespaces:

```bash
# Check disk usage
df -h
du -sh ~/.gradle /opt/android-sdk

# Clean Gradle caches (frees space but slows next build)
./gradlew clean
rm -rf ~/.gradle/caches/
```

### Slow first build

Expected behaviour — Gradle downloads all dependencies the first time.
Enable the Gradle cache and persistent volume (already configured) to speed up
subsequent builds.
