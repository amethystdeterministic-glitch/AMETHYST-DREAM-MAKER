#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] injecting D.R.E..."

sed -i '/# EXECUTE (ONLY ONCE)/,$d' "$TARGET"

cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# D.R.E. ENFORCEMENT + EXECUTION
# ----------------------------
python - <<PY
import json
import sys
sys.path.append("/data/data/com.termux/files/home/repos/odin_os")

from dre_enforcer import enforce, execute

parsed = """$PARSED"""
dry_run = $DRY_RUN

try:
    actions = json.loads(parsed)
except:
    actions = []

enforced, rejected = enforce(actions)

if rejected:
    print(json.dumps({"rejected": rejected}, indent=2))

results = execute(enforced, dry_run=dry_run)

for r in results:
    print(json.dumps(r))
PY

BLOCK

echo "[PATCH] done"
