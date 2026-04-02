#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[REBUILD] creating clean deterministic core..."

cat <<'CLEAN' > "$TARGET"
#!/usr/bin/env bash
set -euo pipefail

USER_INTENT="${1:-}"
AUTH="${2:-USER}"
DRY_RUN=0

if [ "${2:-}" = "--dry-run" ] || [ "${3:-}" = "--dry-run" ]; then
  DRY_RUN=1
fi

STATE_FILE="$HOME/repos/odin_os/engine_state.json"
LEDGER="$HOME/repos/odin_os/ledger.jsonl"

mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"
touch "$LEDGER"

[ ! -s "$STATE_FILE" ] && echo '{"engines":{}}' > "$STATE_FILE"

call_qwen () {
  PROMPT=$(cat <<EOP
Convert this into a JSON ARRAY of actions:
[{"action":"...","payload":"..."}]

Allowed actions: deploy, test, status
Return ONLY JSON array.

User intent:
$USER_INTENT
EOP
)

  JSON=$(printf "%s" "$PROMPT" | python - <<'PY'
import json,sys
print(json.dumps({"prompt":sys.stdin.read(),"temperature":0.0,"max_tokens":128}))
PY
)

  curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON"
}

RAW=$(call_qwen)

PARSED=$(echo "$RAW" | python - <<'PY'
import json,re,sys

try:
    data=json.load(sys.stdin)
    content=data.get("content","")
except:
    print("[]"); exit()

m=re.search(r'\[.*\]',content,re.S)
if not m:
    print("[]"); exit()

try:
    arr=json.loads(m.group(0))
    print(json.dumps(arr))
except:
    print("[]")
PY
)

echo "[PARSED] $PARSED"

echo "$PARSED" | python - <<'PY' | while read -r line; do
import json,sys
for x in json.load(sys.stdin):
    print(f"{x.get('action')}::{x.get('payload','none')}")
PY
  ACTION="${line%%::*}"
  PAYLOAD="${line##*::}"
  PAYLOAD="${PAYLOAD// /_}"

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "{\"action\":\"$ACTION\",\"payload\":\"$PAYLOAD\",\"status\":\"SIMULATED\"}"
    continue
  fi

  case "$ACTION" in
    deploy)
      python - <<PY
import json
f="$STATE_FILE"
d=json.load(open(f))
d["engines"]["$PAYLOAD"]="running"
json.dump(d,open(f,"w"))
PY
      echo "{\"action\":\"deploy\",\"payload\":\"$PAYLOAD\",\"status\":\"ENFORCED\"}"
      ;;
    status)
      STATE=$(cat "$STATE_FILE")
      echo "{\"status\":\"OK\",\"state\":$STATE}"
      ;;
    delete)
      if [ "$AUTH" != "ROOT" ]; then
        echo "{\"action\":\"delete\",\"status\":\"REJECTED\",\"reason\":\"requires_authority\"}"
      else
        echo '{"engines":{}}' > "$STATE_FILE"
        echo "{\"action\":\"delete\",\"status\":\"ENFORCED\"}"
      fi
      ;;
  esac

done
CLEAN

chmod +x "$TARGET"

echo "[REBUILD] clean core ready"
echo "Run: bash $TARGET \"deploy engine alpha\" --dry-run"
