#!/usr/bin/env bash
set -euo pipefail

WORK="$HOME/repos/odin_os/recovery/v5_branch"
APK="$WORK/base.apk"
OUT="$WORK/decoded"

rm -rf "$OUT"
apktool d -f "$APK" -o "$OUT"

echo "DECODE_COMPLETE"
echo "OUT=$OUT"
