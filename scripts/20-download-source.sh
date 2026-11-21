#!/usr/bin/env bash
set -Eeuo pipefail

: "${WINE_VERSION:?}"
: "${WINE_SOURCE_SHA256:?}"
mkdir -p /tmp/wine-source
cd /tmp/wine-source

case "$WINE_VERSION" in
  11.0) source_url='https://dl.winehq.org/wine/source/11.0/wine-11.0.tar.xz' ;;
  *) echo 'Unexpected version; update the pinned hash before changing source' >&2; exit 1 ;;
esac

curl --fail --location --show-error --silent --retry 3 \
  --proto '=https' --tlsv1.2 "$source_url" -o "wine-${WINE_VERSION}.tar.xz"
printf '%s  %s\n' "$WINE_SOURCE_SHA256" "wine-${WINE_VERSION}.tar.xz" | sha256sum --check --status
sha256sum "wine-${WINE_VERSION}.tar.xz"
tar -xJf "wine-${WINE_VERSION}.tar.xz"
test -x "/tmp/wine-source/wine-${WINE_VERSION}/configure"
