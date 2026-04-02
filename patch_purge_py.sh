#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] purging ALL python fragments..."

# Remove any inline python -c blocks
sed -i '/python -c/,/)/d' "$TARGET"

# Remove ANY heredoc python blocks that are not quoted (unsafe)
sed -i '/python - <<PY/,/PY/d' "$TARGET"

# Remove stray Python keywords that leaked
sed -i '/except:/d' "$TARGET"
sed -i '/try:/d' "$TARGET"

echo "[PATCH] done"
