#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] locating broken block..."

# Remove broken retry block (likely malformed sed injection)
sed -i '/# ================================/{
  :a
  N
  /TIMEOUT \+ RETRY GUARD/!ba
  d
}' "$TARGET"

echo "[FIX] removing malformed lines around raw (post-retry)..."
sed -i '/raw (post-retry)/d' "$TARGET"

echo "[FIX] re-inserting clean call_qwen + retry block..."

cat <<'CLEAN' >> "$TARGET"

# ================================
# TIMEOUT + RETRY GUARD (CLEAN)
# ================================

call_qwen () {
  PROMPT=$(cat <<EOP
Convert this into a JSON ARRAY of actions:
[{"action":"...","payload":"..."}]

Allowed actions: deploy, test, status
- Multiple steps allowed
- Return ONLY JSON array
- No explanation
- No markdown

User intent:
$USER_INTENT
EOP
)

  JSON_PAYLOAD=$(printf "%s" "$PROMPT" | python - <<'PY'
import json, sys
print(json.dumps({
    "prompt": sys.stdin.read(),
    "temperature": 0.0,
    "max_tokens": 256
}))
PY
)

  timeout 8 curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD"
}

RETRIES=0
MAX_RETRIES=2
RAW=""

while [ $RETRIES -le $MAX_RETRIES ]; do
  RAW=$(call_qwen || true)

  if [ -n "$RAW" ]; then
    break
  fi

  echo "[RETRY] Qwen call failed, retry $RETRIES..."
  RETRIES=$((RETRIES+1))
  sleep 1
done

if [ -z "$RAW" ]; then
  echo "[GUARD] Qwen unavailable → HARD BLOCK"
  exit 1
fi

echo "[PILGRIM AI] raw:"
echo "$RAW"

CLEAN

echo "[FIX] done"
