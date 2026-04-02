#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v4.sh"

echo "[FIX] removing ALL legacy execution paths..."

# Delete everything after PARSED line
sed -i '/^\[PARSED\]/,$d' "$TARGET"

# Append clean deterministic execution
cat <<'BLOCK' >> "$TARGET"

echo "[PARSED] $PARSED"

# ----------------------------
# EXECUTION (FINAL)
# ----------------------------
python - <<PY
import json, os

parsed = """$PARSED"""
dry_run = 1 if "--dry-run" in os.environ.get("ARGS","") else 0
state_file = os.path.expanduser("~/repos/odin_os/engine_state.json")
auth = os.environ.get("AUTH","USER")

try:
    data = json.loads(parsed)
except:
    data = []

for x in data:
    action = x.get("action","")
    payload = x.get("payload","none").replace(" ", "_")

    if not action:
        continue

    if dry_run:
        print(json.dumps({"action":action,"payload":payload,"status":"SIMULATED"}))
        continue

    if action == "deploy":
        d = json.load(open(state_file))
        d["engines"][payload] = "running"
        json.dump(d, open(state_file,"w"))
        print(json.dumps({"action":"deploy","payload":payload,"status":"ENFORCED"}))

    elif action == "status":
        print(json.dumps({"status":"OK","state":json.load(open(state_file))}))

    elif action == "delete":
        if auth != "ROOT":
            print(json.dumps({"action":"delete","status":"REJECTED","reason":"requires_authority"}))
        else:
            json.dump({"engines":{}}, open(state_file,"w"))
            print(json.dumps({"action":"delete","status":"ENFORCED"}))
PY

BLOCK

echo "[FIX] done"
