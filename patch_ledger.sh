#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] injecting ledger..."

sed -i '/# D.R.E. ENFORCEMENT + EXECUTION/,$d' "$TARGET"

cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# D.R.E. ENFORCEMENT + EXECUTION + LEDGER
# ----------------------------
python - <<PY
import json
import sys
sys.path.append("/data/data/com.termux/files/home/repos/odin_os")

from dre_enforcer import enforce, execute
from dre_ledger import write_entry

intent = """$1"""
parsed_raw = """$PARSED"""
dry_run = $DRY_RUN

try:
    parsed = json.loads(parsed_raw)
except:
    parsed = []

enforced, rejected = enforce(parsed)
results = execute(enforced, dry_run=dry_run)

entry = write_entry(intent, parsed, rejected, results)

# OUTPUT
if rejected:
    print(json.dumps({"rejected": rejected}, indent=2))

for r in results:
    print(json.dumps(r))

PY

BLOCK

echo "[PATCH] done"
