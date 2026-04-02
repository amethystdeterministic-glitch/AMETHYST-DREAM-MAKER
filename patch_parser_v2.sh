#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[PATCH] upgrading parser..."

sed -i '/# PARSE SECTION START/,/# PARSE SECTION END/d' "$TARGET"

cat <<'BLOCK' >> "$TARGET"

# ----------------------------
# PARSE SECTION START
# ----------------------------
PARSED=$(python - <<PY
import sys
sys.path.append("/data/data/com.termux/files/home/repos/odin_os")

from parser_v2 import parse

raw = """$RAW"""

actions = parse(raw)

import json
print(json.dumps(actions))
PY
)

echo "[PARSED] $PARSED"
# ----------------------------
# PARSE SECTION END
# ----------------------------

BLOCK

echo "[PATCH] done"
