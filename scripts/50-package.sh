#!/usr/bin/env bash
set -Eeuo pipefail
: "${WINE_INSTALL_PREFIX:?}"
mkdir -p dist

# Preserve the install prefix; this is also the intended path on Nagi's PC.
tar -C /workspace/shared \
  -I 'zstd -T2 -6' -cf dist/wine11-wow64-debian13.tar.zst line-wow64-11.0
sha256sum dist/wine11-wow64-debian13.tar.zst > dist/SHA256SUMS
cp /tmp/wine-pe32-identification.txt /tmp/wow64-command.log /tmp/wow64-status.txt dist/
{
  echo "Wine version: ${WINE_VERSION}"
  echo "Source SHA256: ${WINE_SOURCE_SHA256}"
  echo "Install prefix: ${WINE_INSTALL_PREFIX}"
  echo 'WoW64 layout:'
  find "${WINE_INSTALL_PREFIX}" -type d -path '*/wine/*' |
    grep -E '/(i386-windows|x86_64-windows|x86_64-unix|i386-unix)$' || true
  echo 'Test: 32-bit bundled cmd.exe with WOW64_OK and exit 0'
} > dist/BUILD-MANIFEST.txt
ls -lh dist
