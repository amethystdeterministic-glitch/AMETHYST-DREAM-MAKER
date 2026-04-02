#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6"
APK="$ROOT/pilgrim_v6.apk"

if [ ! -f "$APK" ]; then
  echo "ERROR: APK not found at $APK"
  exit 1
fi

termux-open --content-type application/vnd.android.package-archive "$APK"
echo "INSTALL_TRIGGER_SENT"
echo "APK=$APK"
