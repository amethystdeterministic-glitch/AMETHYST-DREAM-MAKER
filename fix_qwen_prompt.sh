#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] patching Qwen prompt (safe JSON encoding)..."

sed -i '/call_qwen () {/,/}/c\
call_qwen () {\
  PROMPT=$(cat <<EOP\
Convert this into a JSON ARRAY of actions:\
[{\"action\":\"...\",\"payload\":\"...\"}]\
\
Allowed actions: deploy, test, status\
- Multiple steps allowed\
- Return ONLY JSON array\
- No explanation\
- No markdown\
\
User intent:\
$USER_INTENT\
EOP\
)\
\
  JSON_PAYLOAD=$(printf "%s" "$PROMPT" | python -c "import json,sys; print(json.dumps({'prompt': sys.stdin.read(), 'temperature':0.0, 'max_tokens':256}))")\
\
  timeout 8 curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD"\
}\
' "$TARGET"

echo "[FIX] done"
