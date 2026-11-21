#!/usr/bin/env bash
set -Eeuo pipefail
: "${WINE_VERSION:?}"
: "${WINE_INSTALL_PREFIX:?}"

# The install path is intentionally the same on CI and on Nagi's cloud PC.
case "$WINE_INSTALL_PREFIX" in
  /workspace/shared/line-wow64-11.0) ;;
  *) echo 'Refusing an unapproved install prefix' >&2; exit 1 ;;
esac

mkdir -p /tmp/wine-build
cd /tmp/wine-build
"/tmp/wine-source/wine-${WINE_VERSION}/configure" \
  --prefix="$WINE_INSTALL_PREFIX" \
  --disable-tests \
  --enable-archs=i386,x86_64 \
  2>&1 | tee /tmp/wine-configure.log

# Avoid out-of-memory spikes on standard 4-core runners.
make -j3 2>&1 | tee /tmp/wine-make.log
make install 2>&1 | tee /tmp/wine-install.log

"$WINE_INSTALL_PREFIX/bin/wine" --version
