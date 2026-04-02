#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/dre_ledger.py"

echo "[UPGRADE] chaining ledger..."

cat <<'PY' > "$TARGET"
import json
import time
import os
import hashlib

LEDGER_PATH = os.path.expanduser("~/repos/odin_os/ledger.jsonl")

def get_last_hash():
    if not os.path.exists(LEDGER_PATH):
        return "GENESIS"

    try:
        with open(LEDGER_PATH, "r") as f:
            lines = f.readlines()
            if not lines:
                return "GENESIS"
            last = json.loads(lines[-1])
            return last.get("entry_hash", "GENESIS")
    except:
        return "GENESIS"

def write_entry(intent, parsed, rejected, executed):
    prev_hash = get_last_hash()

    entry = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "intent": intent,
        "parsed": parsed,
        "rejected": rejected,
        "executed": executed,
        "prev_hash": prev_hash
    }

    entry_str = json.dumps(entry, sort_keys=True)
    entry_hash = hashlib.sha256(entry_str.encode()).hexdigest()

    entry["entry_hash"] = entry_hash

    with open(LEDGER_PATH, "a") as f:
        f.write(json.dumps(entry) + "\n")

    return entry
PY

echo "[UPGRADE] done"
