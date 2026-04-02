#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[FIX] removing inline ledger + forcing module usage..."

# Remove ANY inline ledger writes
sed -i '/ledger_entry = {/,/f.write/d' "$TARGET"
sed -i '/with open(ledger_file/,/f.write/d' "$TARGET"

# Ensure dre_ledger import exists
grep -q "from dre_ledger import write_entry" "$TARGET" || \
sed -i '/import hashlib/a from dre_ledger import write_entry' "$TARGET"

# Replace final output section to use write_entry
sed -i 's|print(json.dumps(row))|print(json.dumps(row))|' "$TARGET"

# Inject proper ledger call before output loop
sed -i '/executed.append/a\
entry = write_entry(intent, parsed, rejected, executed)' "$TARGET"

echo "[FIX] done"
