#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] ensuring RAW is always defined..."

# Insert RAW guard near top of file (after shebang)
sed -i '2i\
RAW="${RAW:-""}"\
' "$TARGET"

echo "[PATCH] done"
