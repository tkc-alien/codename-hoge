# api =========================================================================

FROM node:22-bookworm-slim AS api

# Update repository
RUN npm install -g npm@11.2.0

# Install: nestjs
RUN npm install -g @nestjs/cli@11.0.5

# app =========================================================================

FROM debian:bookworm-slim AS app

COPY app/ .

# Update repository & Install common tools
RUN apt update -y && apt install -y curl git unzip

ENV PATH="/root/.pub-cache/bin:/root/fvm/default/bin:$PATH"

# Install: FVM
RUN curl -fsSL https://fvm.app/install.sh | bash \
    && FLUTTER_VERSION=$(grep '"flutter":' .fvmrc | sed -E 's/.*"flutter":\s*"([^"]+)".*/\1/') \
    && yes | fvm install $FLUTTER_VERSION \
    && yes | fvm global $FLUTTER_VERSION \
    && flutter doctor \
    && rm -f .fvmrc

# Clean up
RUN apt clean && rm -rf /var/lib/apt/lists/*

# db ==========================================================================

FROM postgres:17-bookworm AS db

# Update repository
RUN apt update -y

# Setup: locale
RUN apt install -y locales \
    && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8

# Setup: TimeZone
ENV TZ=Asia/Tokyo

# Clean up
RUN apt clean && rm -rf /var/lib/apt/lists/*

# workspace ===================================================================

# Install: docker
FROM debian:bookworm-slim AS install-docker
RUN apt update -y && apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo " \
        deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
        https://download.docker.com/linux/debian $(lsb_release -cs) stable \
        " | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update -y \
    && apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Install: just
FROM debian:bookworm-slim AS install-just
RUN apt update -y && apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
    && curl -fsSL https://proget.makedeb.org/debian-feeds/prebuilt-mpr.pub | gpg --dearmor -o /usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg \
    && echo " \
        deb [arch=all,$(dpkg --print-architecture) signed-by=/usr/share/keyrings/prebuilt-mpr-archive-keyring.gpg] \
        https://proget.makedeb.org prebuilt-mpr $(lsb_release -cs) \
        " | tee /etc/apt/sources.list.d/prebuilt-mpr.list > /dev/null \
    && apt update -y \
    && apt install -y just

# Base image
FROM debian:bookworm-slim AS workspace

# Apply application stages
COPY --from=api /usr/local /usr/local
COPY --from=app /usr/local /usr/local
COPY --from=app /root/fvm /root/fvm
COPY --from=app /root/.config /root/.config
ENV PATH="/usr/local/bin:$PATH"
ENV PATH="/root/fvm/default/bin:$PATH"
ENV FLUTTER_ROOT="/root/fvm/default"

# Apply install stages
COPY --from=install-docker /usr/bin/docker /usr/bin/docker
COPY --from=install-docker /usr/bin/dockerd /usr/bin/dockerd
COPY --from=install-docker /usr/bin/containerd /usr/bin/containerd
COPY --from=install-docker /usr/libexec/docker /usr/libexec/docker
COPY --from=install-just /usr/bin/just /usr/bin/just

# Update repository & Install common tools
RUN apt update -y && apt install -y \
        ca-certificates \
        curl \
        zip \
        unzip

# Setup: locale
RUN apt install -y locales \
    && locale-gen ja_JP.UTF-8 \
    && echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

# Install: git
RUN apt install -y --no-install-recommends git \
    && git config --global --add safe.directory /flatten

# Clean up
RUN apt clean && rm -rf /var/lib/apt/lists/*
