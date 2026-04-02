#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/repos/odin_os/artifacts/apk_gold/pilgrim_v5_GOLD.apk"
WORK="$HOME/repos/odin_os/recovery/v5_branch"

rm -rf "$WORK"
mkdir -p "$WORK"

cp "$BASE" "$WORK/base.apk"

echo "BRANCH_READY"
echo "WORK=$WORK"
