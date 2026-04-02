#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] patching safe parser..."

sed -i '/PARSED=$(echo "$RAW"/,/PY/c\
PARSED=$(echo "$RAW" | python - <<'\''PY'\''\
import json,re,sys\
\
try:\
    data=json.load(sys.stdin)\
    content=data.get("content","")\
except:\
    print("[]")\
    sys.exit(0)\
\
m=re.search(r"\[.*?\]", content, re.S)\
\
if not m:\
    print("[]")\
    sys.exit(0)\
\
try:\
    arr=json.loads(m.group(0))\
    if not isinstance(arr, list):\
        print("[]")\
    else:\
        print(json.dumps(arr))\
except:\
    print("[]")\
PY\
)' "$TARGET"

echo "[FIX] done"
