#!/usr/bin/env bash
set -euo pipefail

V5="$HOME/repos/odin_os/artifacts/apk_gold/pilgrim_v5_GOLD.apk"
DEX="$HOME/repos/odin_os/amethyst/arm_apk_engine_v6/build/classes.dex"
OUT="$HOME/repos/odin_os/artifacts/apk_gold/pilgrim_v6_patched.apk"

WORK="$HOME/repos/odin_os/tmp_patch"
rm -rf "$WORK"
mkdir -p "$WORK"

cd "$WORK"

# unzip base APK
unzip "$V5"

# replace dex
cp "$DEX" classes.dex

# rebuild APK
zip -r "$OUT" *

echo "PATCH_COMPLETE"
echo "APK=$OUT"
