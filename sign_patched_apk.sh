#!/usr/bin/env bash
set -euo pipefail

APK="$HOME/repos/odin_os/artifacts/apk_gold/pilgrim_v6_patched.apk"

apksigner sign \
  --ks "$HOME/repos/odin_os/debug.keystore" \
  --ks-pass pass:android \
  "$APK"

echo "SIGNED"
