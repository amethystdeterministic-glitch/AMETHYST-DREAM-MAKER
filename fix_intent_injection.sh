#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] forcing USER_INTENT injection..."

sed -i '/call_qwen () {/,/^}/c\
call_qwen () {\
  if [ -z "$USER_INTENT" ]; then\
    echo "[ERROR] empty USER_INTENT"\
    exit 1\
  fi\
\
  PROMPT="Convert this into a JSON ARRAY of actions:\n[{\"action\":\"...\",\"payload\":\"...\"}]\n\nAllowed actions: deploy, test, status\nReturn ONLY JSON array.\n\nUser intent:\n$USER_INTENT"\
\
  echo "[DEBUG] PROMPT:"\
  echo "$PROMPT"\
\
  JSON=$(printf "%s" "$PROMPT" | python - <<'\''PY'\''\
import json,sys\
print(json.dumps({\
  "prompt": sys.stdin.read(),\
  "temperature": 0.0,\
  "max_tokens": 128\
}))\
PY\
)\
\
  curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON"\
}\
' "$TARGET"

echo "[FIX] done"
