#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v4.sh"

echo "[FIX] forcing PARSED initialization at top..."

TMP="$(mktemp)"

{
  read -r first
  echo "$first"

  cat <<'BLOCK'
PARSED="[]"
BLOCK

  cat
} < "$TARGET" > "$TMP"

mv "$TMP" "$TARGET"

echo "[FIX] done"
