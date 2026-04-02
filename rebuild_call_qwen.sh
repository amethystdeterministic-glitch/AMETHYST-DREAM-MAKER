#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[REBUILD] replacing call_qwen with deterministic-safe version..."

# remove existing call_qwen block
sed -i '/call_qwen () {/,/^}/d' "$TARGET"

# append clean implementation at top of file (after shebang)
TMP_FILE="$(mktemp)"

{
  read -r first_line
  echo "$first_line"
  echo ""
  cat <<'FUNC'

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

FUNC
  cat
} < "$TARGET" > "$TMP_FILE"

mv "$TMP_FILE" "$TARGET"

echo "[REBUILD] done"
