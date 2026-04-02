#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FORCE FIX] fixing unsafe parentheses in strings..."

# replace problematic commit line with safe version (no parentheses)
sed -i 's/FINAL FREEZE: PILGRIM MULTI ENFORCE V1 STABLE (.*)/FINAL FREEZE: PILGRIM MULTI ENFORCE V1 STABLE/g' "$TARGET"

# also remove any remaining raw parentheses in echo/commit contexts
sed -i 's/(//g' "$TARGET"
sed -i 's/)//g' "$TARGET"

echo "[FORCE FIX] syntax re-check..."
bash -n "$TARGET"

echo "[FORCE FIX] complete"
