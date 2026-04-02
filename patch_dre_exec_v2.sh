#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] replacing execution block (heredoc-safe)..."

# Remove everything from execution section downward
sed -i '/# D.R.E. ENFORCEMENT/, $d' "$TARGET"

# Append clean execution block
cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# D.R.E. ENFORCEMENT + EXECUTION + LEDGER (HEREDOC SAFE)
# ----------------------------
python - <<'PY'
import json
import sys
import time

sys.path.append("/data/data/com.termux/files/home/repos/odin_os")

from dre_enforcer import enforce, execute
from dre_ledger import write_entry

intent = """$1"""
parsed_raw = """$PARSED"""
dry_run = True if "$DRY_RUN" == "1" else False

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
