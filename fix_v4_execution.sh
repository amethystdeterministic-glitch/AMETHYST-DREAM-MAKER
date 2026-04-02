#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v4.sh"

echo "[FIX] cleaning execution + dry-run handling..."

# Fix DRY_RUN detection
sed -i 's/AUTH="${2:-USER}"/AUTH="USER"/' "$TARGET"

sed -i '/DRY_RUN=0/a\
for arg in "$@"; do\
  if [ "$arg" = "--dry-run" ]; then\
    DRY_RUN=1\
  fi\
done' "$TARGET"

# Remove raw echo of PARSED (keep only debug)
sed -i '/^echo "\$PARSED"$/d' "$TARGET"

echo "[FIX] done"
