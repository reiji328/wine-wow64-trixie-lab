#!/usr/bin/env bash
set -Eeuo pipefail
: "${WINE_INSTALL_PREFIX:?}"

# Key gate: BOTH native Windows PE architecture trees, NO Linux i386 tree.
base="$WINE_INSTALL_PREFIX"
libdir="$(find "$base" -type d -path '*/wine/i386-windows' -print -quit)"
test -n "$libdir" || { echo 'ERROR: no i386-windows tree (not new WoW64)' >&2; exit 1; }
test -d "${libdir%/i386-windows}/x86_64-windows" || { echo 'ERROR: no x86_64-windows tree' >&2; exit 1; }
test -d "${libdir%/i386-windows}/x86_64-unix" || { echo 'ERROR: no x86_64-unix tree' >&2; exit 1; }
if find "$base" -type d -path '*/wine/i386-unix' | grep -q .; then
  echo 'ERROR: unexpected Linux i386 tree' >&2
  exit 1
fi

for arch in i386-windows x86_64-windows x86_64-unix; do
  count="$(find "${libdir%/i386-windows}/$arch" -type f | wc -l)"
  printf '%s: %s files\n' "$arch" "$count"
  test "$count" -gt 20
done

cmd="$libdir/cmd.exe"
test -f "$cmd" || { echo 'ERROR: missing i386-windows/cmd.exe' >&2; exit 1; }
file "$cmd" | tee /tmp/wine-pe32-identification.txt
grep -qi 'PE32.*Intel 80386\|PE32.*Intel i386' /tmp/wine-pe32-identification.txt || {
  echo 'ERROR: bundled command is not PE32 x86' >&2; exit 1;
}

# Running as root is not a representative or safe Wine end-user test.
useradd --create-home --shell /bin/bash wine-check
runuser -u wine-check -- mkdir -p /home/wine-check/wine-prefix

# Prevent graphical dependencies from blocking the Windows command test.
runuser -u wine-check -- env \
  WINEPREFIX=/home/wine-check/wine-prefix \
  WINEARCH=wow64 WINEDEBUG=err+all WINEDLLOVERRIDES=mscoree,mshtml= \
  timeout 180s xvfb-run --auto-servernum "$base/bin/wineboot" -u 2>&1 | tee /tmp/wineboot.log

set +e
runuser -u wine-check -- env \
  WINEPREFIX=/home/wine-check/wine-prefix \
  WINEARCH=wow64 WINEDEBUG=err+all WINEDLLOVERRIDES=mscoree,mshtml= \
  timeout 120s xvfb-run --auto-servernum "$base/bin/wine" \
  'C:\windows\syswow64\cmd.exe' /d /c 'echo WOW64_OK' \
  > /tmp/wow64-command.log 2>&1
rc=$?
set -e
cat /tmp/wow64-command.log
printf 'WOW64_CMD_EXIT_CODE=%s\n' "$rc" | tee /tmp/wow64-status.txt
[ "$rc" -eq 0 ] || { echo 'ERROR: 32-bit cmd failed' >&2; exit 1; }
grep -Fq 'WOW64_OK' /tmp/wow64-command.log || {
  echo 'ERROR: 32-bit cmd produced no success marker' >&2; exit 1;
}
echo 'PASS: 32-bit Windows cmd executed on Debian 13 amd64 without i386 Linux runtime.'
