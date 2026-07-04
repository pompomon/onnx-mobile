# onnx-mobile
Android apk to use onnx models for text and image generation

---

## Building in GitHub Codespaces

This repository uses **GitHub Codespaces as the primary build environment**.
Full APK builds run inside Codespaces — not GitHub Actions — to keep CI
minutes low and provide a rich IDE experience.

### Quick start

1. Click **Code → Codespaces → Create codespace on main** (choose ≥ 8-core / 16 GB).
2. Wait for container setup to finish (~3–5 min on first run).
3. In the integrated terminal:

```bash
make apk-debug    # build a debug APK
make apk-release  # build a release APK (requires signing secrets)
make check        # lint + unit tests
make clean        # remove build outputs
```

### Documentation

See **[docs/codespaces-android.md](docs/codespaces-android.md)** for:

- Machine size recommendations
- Full daily workflow
- Release signing via Codespaces secrets
- GitHub Actions (minimal) strategy
- Troubleshooting guide

### GitHub Actions

A lightweight **lint-only** workflow (`.github/workflows/android-check.yml`)
runs on every PR and push to `main`. It does **not** build APKs — that is done
in Codespaces.

