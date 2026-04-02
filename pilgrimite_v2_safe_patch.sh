#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v2.sh"

echo "[PATCH] Making Qwen output safe (no jq crash)..."

sed -i '/extract_text()/,/^}/c\
extract_text() {\
  RAW="$1"\
  echo "$RAW"\
}' "$FILE"

# Replace run section to avoid jq parsing Qwen output
sed -i '/RAW=$(call_qwen/,/echo "\[DONE\]/c\
  RAW=$(call_qwen "$PROMPT")\
\
  echo "$RAW" > "$RAW_FILE"\
\
  echo "{\"result\":\"ok\"}" > "$RESULT_FILE"\
  echo "$RAW" > "$READABLE_FILE"\
\
  mark_completed "$TASK_FILE"\
  append_ledger "$NAME" "$RESULT_FILE" "$READABLE_FILE" "$TASK_FILE"\
\
  echo "[DONE] $NAME"' "$FILE"

echo "[PATCH] COMPLETE"
