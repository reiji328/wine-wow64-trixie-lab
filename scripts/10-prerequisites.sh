#!/usr/bin/env bash
set -Eeuo pipefail

# Executes ONLY inside the disposable GitHub-hosted Debian 13 container.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  build-essential gcc g++ make pkg-config bison flex \
  mingw-w64 binutils-mingw-w64 \
  git curl ca-certificates xz-utils zstd tar file python3 \
  libx11-dev libxext-dev libxrandr-dev libxinerama-dev libxcursor-dev \
  libxi-dev libxcomposite-dev libxrender-dev libxfixes-dev libxkbcommon-dev \
  libfreetype-dev libfontconfig1-dev libgl-dev \
  libgnutls28-dev libasound2-dev libpulse-dev \
  libdbus-1-dev libxml2-dev libxslt1-dev \
  libjpeg-dev libpng-dev libtiff-dev \
  libvulkan-dev libudev-dev libusb-1.0-0-dev \
  libcups2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  gettext gawk xvfb xauth x11-utils procps util-linux

printf '\n[toolchains]\n'
uname -m
ldd --version | head -1
command -v x86_64-w64-mingw32-gcc
command -v i686-w64-mingw32-gcc

# Do NOT install the Linux i386 execution stack; the point is to test new WoW64.
if dpkg --print-foreign-architectures | grep -qx i386; then
  echo 'ERROR: Unexpected i386 Linux architecture enabled in CI' >&2
  exit 1
fi
