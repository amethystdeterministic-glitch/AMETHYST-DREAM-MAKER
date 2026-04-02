#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] restoring Qwen RAW generation..."

sed -i '1,/RAW="/d' "$TARGET"

cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# QWEN CALL (RAW GENERATION)
# ----------------------------
PROMPT="Convert to JSON actions:
[{\"action\":\"...\",\"payload\":\"...\"}]
Allowed: deploy, test, status
User: $1"

RAW=$(curl -s http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d "{
    \"prompt\": \"$PROMPT\",
    \"temperature\": 0.0,
    \"n_predict\": 128
  }")

echo "[RAW] $RAW"

BLOCK

echo "[PATCH] done"
