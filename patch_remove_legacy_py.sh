#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] removing ALL legacy inline python blocks..."

# Remove python -c blocks (common culprit)
sed -i '/python -c/,/)/d' "$TARGET"

# Remove any stray python heredoc blocks BEFORE parser_v2
sed -i '1,/PARSE SECTION START/{/python - <<PY/,/PY/d}' "$TARGET"

echo "[PATCH] done"
