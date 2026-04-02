#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
FREEZE_DIR="$ROOT/artifacts/freeze/$STAMP"

mkdir -p "$FREEZE_DIR"

echo "===================================="
echo "ODIN FREEZE V2 START"
echo "===================================="

# 1. Capture git state (if repo exists)
if git -C "$ROOT" rev-parse >/dev/null 2>&1; then
  git -C "$ROOT" status > "$FREEZE_DIR/git_status.txt" || true
  git -C "$ROOT" log -1 > "$FREEZE_DIR/git_last_commit.txt" || true
fi

# 2. Capture critical files
cp "$ROOT/pilgrim_clean.sh" "$FREEZE_DIR/" 2>/dev/null || true
cp "$ROOT/pilgrim_ai_enforce_v5.sh" "$FREEZE_DIR/" 2>/dev/null || true

# 3. Capture engine state
cp "$ROOT/engine_state.json" "$FREEZE_DIR/" 2>/dev/null || echo '{"engines":{}}' > "$FREEZE_DIR/engine_state.json"

# 4. Capture environment snapshot
env | sort > "$FREEZE_DIR/env_snapshot.txt"

# 5. Create manifest
cat <<MANIFEST > "$FREEZE_DIR/FREEZE_MANIFEST.txt"
FREEZE_ID=$STAMP
SYSTEM=ODIN
STATE=GREEN
PRIMARY_SCRIPT=pilgrim_clean.sh
NOTES=Stable NL→Action pipeline achieved
MANIFEST

echo "Freeze saved to:"
echo "$FREEZE_DIR"

echo "===================================="
echo "FREEZE COMPLETE (GREEN)"
echo "===================================="
