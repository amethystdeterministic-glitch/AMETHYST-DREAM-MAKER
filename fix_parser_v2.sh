#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v3.sh"

echo "[FIX] upgrading parser..."

sed -i '/PARSED=$(echo/,/)/c\
PARSED=$(echo "$RAW" | python -c '"'"'\
import json,re,sys\
try:\
    data=json.load(sys.stdin)\
    content=data.get("content","")\
except:\
    print("[]"); sys.exit(0)\
\
# try array first\
m=re.search(r"\[.*?\]", content, re.S)\
if m:\
    try:\
        arr=json.loads(m.group(0))\
        if isinstance(arr,list):\
            print(json.dumps(arr)); sys.exit(0)\
    except:\
        pass\
\
# fallback: single object\
m=re.search(r"\{[^{}]*\}", content)\
if m:\
    try:\
        obj=json.loads(m.group(0))\
        print(json.dumps([obj])); sys.exit(0)\
    except:\
        pass\
\
print("[]")\
'"'"')' "$TARGET"

echo "[FIX] done"
