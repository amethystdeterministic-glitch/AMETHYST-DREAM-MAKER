#!/data/data/com.termux/files/usr/bin/bash

APK_PATH="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6/pilgrim_v6.apk"

if [ ! -f "$APK_PATH" ]; then
  echo "[FAIL] APK not found at $APK_PATH"
  exit 1
fi

echo "[INSTALL] Launching installer..."

am start \
  -a android.intent.action.VIEW \
  -d "file://$APK_PATH" \
  -t "application/vnd.android.package-archive"

echo "[INSTALL] Intent sent"
