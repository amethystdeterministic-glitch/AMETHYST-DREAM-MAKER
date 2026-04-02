#!/usr/bin/env bash
set -euo pipefail

APK="${1:-}"

if [ -z "$APK" ]; then
  echo "USAGE: $0 /full/path/to/app.apk"
  exit 1
fi

if [ ! -f "$APK" ]; then
  echo "ERROR: APK not found: $APK"
  exit 1
fi

echo "[INSTALL] Opening installer for:"
echo "$APK"

termux-open --content-type application/vnd.android.package-archive "$APK"

echo "[INSTALL] Trigger sent"
