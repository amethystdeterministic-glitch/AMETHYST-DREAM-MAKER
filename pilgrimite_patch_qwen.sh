#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v1.sh"

echo "[PATCH] Fixing Qwen JSON encoding..."

# Replace call_qwen function
sed -i '/call_qwen()/,/^}/c\
call_qwen() {\
  PROMPT="$1"\
  JSON=$(jq -n --arg p "$PROMPT" '\''{prompt: $p, n_predict: 300, temperature: 0.2}'\'')\
  curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON"\
}' "$FILE"

echo "[PATCH] COMPLETE"
