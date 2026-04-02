#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v4.sh"

echo "[FIX] replacing execution loop with deterministic core..."

sed -i '/# ----------------------------/,/# ----------------------------/c\
# ----------------------------\
# EXECUTION (DETERMINISTIC)\
# ----------------------------\
python - <<PY\
import json, os\
\
parsed = """$PARSED"""\
dry_run = int(os.environ.get("DRY_RUN", "0"))\
state_file = os.environ.get("STATE_FILE")\
auth = os.environ.get("AUTH", "USER")\
\
try:\
    data = json.loads(parsed)\
except:\
    data = []\
\
for x in data:\
    action = x.get("action","")\
    payload = x.get("payload","none").replace(" ", "_")\
\
    if not action:\
        continue\
\
    if dry_run == 1:\
        print(json.dumps({"action":action,"payload":payload,"status":"SIMULATED"}))\
        continue\
\
    if action == "deploy":\
        d = json.load(open(state_file))\
        d["engines"][payload] = "running"\
        json.dump(d, open(state_file,"w"))\
        print(json.dumps({"action":"deploy","payload":payload,"status":"ENFORCED"}))\
\
    elif action == "status":\
        print(json.dumps({"status":"OK","state":json.load(open(state_file))}))\
\
    elif action == "delete":\
        if auth != "ROOT":\
            print(json.dumps({"action":"delete","status":"REJECTED","reason":"requires_authority"}))\
        else:\
            json.dump({"engines":{}}, open(state_file,"w"))\
            print(json.dumps({"action":"delete","status":"ENFORCED"}))\
PY' "$TARGET"

echo "[FIX] done"
