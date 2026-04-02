#!/usr/bin/env bash
set -euo pipefail

INTENT="${1:-}"

if [ -z "$INTENT" ]; then
  echo "Usage: pilgrim_ai_enforce.sh \"intent\""
  exit 1
fi

PROMPT=$(cat <<PILGRIM
Convert this into strict JSON only:
{"action":"...","payload":"..."}

Allowed actions: deploy, test, status
Return ONLY ONE JSON object.
No explanation. No markdown.

User intent:
$INTENT
PILGRIM
)

echo "[PILGRIM AI] calling Qwen server..."

REQUEST=$(python - <<PY
import json
print(json.dumps({
    "prompt": """$PROMPT""",
    "n_predict": 128,
    "temperature": 0.0
}))
PY
)

RAW=$(curl -s http://127.0.0.1:8081/completion \
  -H "Content-Type: application/json" \
  -d "$REQUEST")

echo "[PILGRIM AI] raw:"
echo "$RAW"

set +e

JSON=$(RAW_DATA="$RAW" python - <<'PY'
import json, os, re, sys

raw = os.environ.get("RAW_DATA", "").strip()

if not raw:
    print("ERROR: empty model response")
    sys.exit(2)

try:
    data = json.loads(raw)
except Exception:
    print("ERROR: invalid JSON from model")
    sys.exit(3)

content = data.get("content","")

matches = re.findall(r'\{[^{}]*\}', content)

if not matches:
    print("ERROR: no JSON found in model output")
    sys.exit(4)

obj = None
for m in matches:
    try:
        obj = json.loads(m)
        break
    except:
        continue

if obj is None:
    print("ERROR: no valid JSON parsed")
    sys.exit(5)

payload = obj.get("payload","").strip()
if payload == "":
    payload = "none"

obj["payload"] = payload.replace(" ", "_")

print(json.dumps(obj))
PY
)

STATUS=$?

set -e

if [ $STATUS -ne 0 ]; then
  echo "[PILGRIM AI] parser failed:"
  echo "$JSON"
  exit 1
fi

echo "[PILGRIM AI] parsed:"
echo "$JSON"

ACTION=$(echo "$JSON" | python -c 'import json,sys; print(json.load(sys.stdin)["action"])')

if [ "$ACTION" = "status" ]; then
  echo "[PILGRIM AI] routing to /status"
  curl -s http://127.0.0.1:7878/status
  echo
  exit 0
fi

echo "[PILGRIM AI] forwarding to D.R.E..."

curl -s -X POST http://127.0.0.1:7878/enforce \
  -H "Content-Type: application/json" \
  -d "$JSON"

echo
