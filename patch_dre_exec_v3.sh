#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] fixing execution (env-injected)..."

# Remove execution block
sed -i '/# D.R.E. ENFORCEMENT/, $d' "$TARGET"

# Append fixed block
cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# D.R.E. ENFORCEMENT + EXECUTION + LEDGER (ENV SAFE)
# ----------------------------
INTENT="$1"
PARSED_JSON="$PARSED"
DRY_FLAG="$DRY_RUN"

python - <<'PY'
import json
import os
import sys

sys.path.append("/data/data/com.termux/files/home/repos/odin_os")

from dre_enforcer import enforce, execute
from dre_ledger import write_entry

intent = os.environ.get("INTENT", "")
parsed_raw = os.environ.get("PARSED_JSON", "")
dry_run = True if os.environ.get("DRY_FLAG") == "1" else False

try:
    parsed = json.loads(parsed_raw)
except:
    parsed = []

enforced, rejected = enforce(parsed)
results = execute(enforced, dry_run=dry_run)

entry = write_entry(intent, parsed, rejected, results)

if rejected:
    print(json.dumps({"rejected": rejected}, indent=2))

for r in results:
    print(json.dumps(r))
PY

BLOCK

echo "[PATCH] done"
