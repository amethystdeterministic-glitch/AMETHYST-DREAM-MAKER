#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_enforce_v4.sh"

echo "[FIX] ensuring PARSED is always defined..."

# Insert default PARSED="" before parser section
sed -i '1,/RAW=/s/RAW=/PARSED="[]"\nRAW=/' "$TARGET"

echo "[FIX] done"
