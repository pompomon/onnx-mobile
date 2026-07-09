# Dockerfile for onnx-mobile Android development in GitHub Codespaces
# Base: Ubuntu 22.04 (jammy) — stable LTS, well-supported by Android toolchain
FROM ubuntu:22.04

# Prevent interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# ── System packages ──────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    lib32stdc++6 \
    lib32z1 \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ── Android SDK ───────────────────────────────────────────────────────────────
# Versions pinned for reproducibility; update as needed.
ARG CMDLINE_TOOLS_VERSION=11076708
ARG ANDROID_SDK_ROOT=/opt/android-sdk

ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}

# Download and install Android command-line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q \
      "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip" \
      -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools-extracted && \
    # Google ships the zip with a "cmdline-tools" subdirectory; move it into place
    mv /tmp/cmdline-tools-extracted/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools-extracted

# ── PATH ─────────────────────────────────────────────────────────────────────
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"

# Accept licenses and install base SDK packages.
# Additional packages (e.g. emulator images) can be added in postCreate.sh.
RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager \
      "platform-tools" \
      "platforms;android-34" \
      "build-tools;34.0.0" \
      "cmdline-tools;latest"

# ── Non-root user (vscode) ────────────────────────────────────────────────────
# Codespaces runs as "vscode" by default.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    # Give the vscode user write access to the SDK directory so sdkmanager
    # can update packages without sudo.
    chown -R ${USERNAME}:${USERNAME} ${ANDROID_SDK_ROOT}

USER ${USERNAME}
WORKDIR /workspace
