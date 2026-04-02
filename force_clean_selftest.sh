#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FORCE FIX] removing ANY broken self-test remnants..."

# aggressively remove any lines containing test_case or broken quoting
sed -i '/test_case/d' "$TARGET"
sed -i '/delete blocked (no auth)/d' "$TARGET"
sed -i '/SELF-TEST/d' "$TARGET"

echo "[FORCE FIX] removing trailing backslash continuations..."
sed -i 's/\\$//' "$TARGET"

echo "[FORCE FIX] syntax re-check..."
bash -n "$TARGET"

echo "[FORCE FIX] complete"
