#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FINALIZE] setting executable permission..."
chmod +x "$SCRIPT"

echo "[FINALIZE] syntax check..."
bash -n "$SCRIPT"

echo "[FINALIZE] done"
