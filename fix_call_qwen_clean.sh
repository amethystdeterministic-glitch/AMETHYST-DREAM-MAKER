#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] rebuilding call_qwen safely..."

# remove existing function
sed -i '/call_qwen () {/,/^}/d' "$TARGET"

# append clean version at top (after shebang)
TMP="$(mktemp)"

{
  read -r first
  echo "$first"

  cat <<'FUNC'

call_qwen () {
  if [ -z "$USER_INTENT" ]; then
    echo "[ERROR] empty USER_INTENT"
    exit 1
  fi

  PROMPT="Convert this into a JSON ARRAY of actions:
[{\"action\":\"...\",\"payload\":\"...\"}]

Allowed actions: deploy, test, status
Return ONLY JSON array.

User intent:
$USER_INTENT"

  echo "[DEBUG] PROMPT:"
  echo "$PROMPT"

  JSON=$(printf "%s" "$PROMPT" | python -c 'import json,sys; print(json.dumps({"prompt":sys.stdin.read(),"temperature":0.0,"max_tokens":128}))')

  curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON"
}

FUNC

  cat
} < "$TARGET" > "$TMP"

mv "$TMP" "$TARGET"

echo "[FIX] done"
