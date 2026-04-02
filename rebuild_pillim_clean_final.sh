#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

cat <<'SCRIPT' > "$TARGET"
#!/usr/bin/env bash
set -euo pipefail

USER_INTENT="${1:-}"
DRY_RUN=0

for arg in "$@"; do
  if [ "$arg" = "--dry-run" ]; then
    DRY_RUN=1
  fi
done

ROOT="$HOME/repos/odin_os"
STATE_FILE="$ROOT/engine_state.json"
LEDGER_FILE="$ROOT/ledger.jsonl"

mkdir -p "$ROOT"
[ -f "$STATE_FILE" ] || echo '{"engines":{}}' > "$STATE_FILE"
[ -f "$LEDGER_FILE" ] || : > "$LEDGER_FILE"

PROMPT=$(cat <<PROMPT_EOF
Convert to JSON actions:
[{"action":"...","payload":"..."}]
Allowed: deploy, test, status
User: $USER_INTENT
PROMPT_EOF
)

JSON_PAYLOAD=$(printf '%s' "$PROMPT" | python -c 'import json,sys; print(json.dumps({"prompt": sys.stdin.read(), "temperature": 0.0, "n_predict": 128}))')

RAW=$(curl -s http://localhost:8081/completion \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

echo "[RAW] $RAW"

PARSED=$(printf '%s' "$RAW" | python -c '
import json,re,sys

try:
    raw = json.load(sys.stdin)
    content = raw.get("content","")
except Exception:
    print("[]")
    raise SystemExit(0)

m = re.search(r"\[[\s\S]*?\]", content)
if m:
    try:
        arr = json.loads(m.group(0))
        print(json.dumps(arr))
        raise SystemExit(0)
    except Exception:
        pass

objs = re.findall(r"\{[^{}]*\}", content)
actions = []
for s in objs:
    try:
        obj = json.loads(s)
        if "action" in obj:
            actions.append(obj)
    except Exception:
        pass

print(json.dumps(actions))
')

echo "[PARSED] $PARSED"

INTENT="$USER_INTENT" \
PARSED_JSON="$PARSED" \
DRY_RUN_FLAG="$DRY_RUN" \
STATE_FILE="$STATE_FILE" \
LEDGER_FILE="$LEDGER_FILE" \
python - <<'PY'
import json
import os
import time
import hashlib

allowed = {"deploy", "test", "status"}

intent = os.environ["INTENT"]
parsed_raw = os.environ["PARSED_JSON"]
dry_run = os.environ["DRY_RUN_FLAG"] == "1"
state_file = os.environ["STATE_FILE"]
ledger_file = os.environ["LEDGER_FILE"]

try:
    parsed = json.loads(parsed_raw)
    if not isinstance(parsed, list):
        parsed = []
except Exception:
    parsed = []

normalized = []
rejected = []

for item in parsed:
    action = item.get("action")
    payload = item.get("payload")
    if payload is None:
        payload = "none"
    payload = str(payload).replace(" ", "_")
    row = {"action": action, "payload": payload}
    if action not in allowed:
        rejected.append({**row, "reason": "not_allowed"})
    else:
        normalized.append(row)

executed = []

with open(state_file, "r") as f:
    state = json.load(f)

for row in normalized:
    action = row["action"]
    payload = row["payload"]

    if dry_run:
        result = {"action": action, "payload": payload, "status": "SIMULATED"}
    else:
        if action == "deploy":
            state["engines"][payload] = "running"
            result = {"action": action, "payload": payload, "status": "ENFORCED"}
        elif action == "test":
            result = {"action": action, "payload": payload, "status": "ENFORCED"}
        elif action == "status":
            result = {"action": action, "payload": payload, "status": "ENFORCED"}
        else:
            result = {"action": action, "payload": payload, "status": "REJECTED", "reason": "not_allowed"}

    proof_src = f'{intent}|{result.get("action")}|{result.get("payload")}|{result.get("status")}|{int(time.time())}'
    result["proof"] = hashlib.sha256(proof_src.encode()).hexdigest()
    executed.append(result)

if not dry_run:
    with open(state_file, "w") as f:
        json.dump(state, f)

ledger_entry = {
    "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "intent": intent,
    "parsed": parsed,
    "rejected": rejected,
    "executed": executed,
}

with open(ledger_file, "a") as f:
    f.write(json.dumps(ledger_entry) + "\n")

if rejected:
    print(json.dumps({"rejected": rejected}, indent=2))

for row in executed:
    if row["action"] == "status":
        print(json.dumps({"status": "OK", "state": state, "proof": row["proof"]}))
    else:
        print(json.dumps(row))
PY
SCRIPT

chmod +x "$TARGET"
echo "[REBUILD] wrote $TARGET"
