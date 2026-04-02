#!/usr/bin/env bash
set -eo pipefail

ROOT="$HOME/repos/odin_os"
FREEZE_DIR="$ROOT/artifacts/freeze/$(date -u +%Y%m%dT%H%M%SZ)"
ANDROID_DIR="/storage/emulated/0/Download/ODIN_FREEZE"

mkdir -p "$FREEZE_DIR"
mkdir -p "$ANDROID_DIR"

echo "===================================="
echo "ODIN HANDOVER V3 GENERATION"
echo "===================================="

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- PROCESS SCAN ---
QWEN_RUNNING=false
QWEN_PID=""

if pgrep -f "llama-server" > /dev/null 2>&1; then
  QWEN_RUNNING=true
  QWEN_PID=$(pgrep -f "llama-server" | head -n 1)
fi

# --- FILE CHECKS ---
ENGINE_EXISTS=false
LEDGER_EXISTS=false

[ -f "$ROOT/pilgrim_clean.sh" ] && ENGINE_EXISTS=true
[ -f "$ROOT/ledger.jsonl" ] && LEDGER_EXISTS=true

# --- LEDGER HEAD ---
LEDGER_HEAD=$(tail -n 1 "$ROOT/ledger.jsonl" 2>/dev/null || echo "{}")

# --- SAFE DIRECTORY SNAPSHOT ---
TREE=$(ls "$ROOT" 2>/dev/null | head -n 100 || echo "snapshot_unavailable")

# --- WRITE JSON ---
cat <<JSON > "$FREEZE_DIR/HANDOVER.json"
{
  "timestamp": "$TIMESTAMP",
  "system": {
    "name": "ODIN / Pilgrim",
    "status": "GREEN"
  },
  "runtime": {
    "qwen_running": $QWEN_RUNNING,
    "qwen_pid": "$QWEN_PID",
    "engine_present": $ENGINE_EXISTS,
    "ledger_present": $LEDGER_EXISTS
  },
  "last_execution": $LEDGER_HEAD,
  "resume": {
    "command": "~/repos/odin_os/odin_on"
  }
}
JSON

# --- WRITE TXT ---
cat <<TXT > "$FREEZE_DIR/HANDOVER.txt"
ODIN HANDOVER

Timestamp: $TIMESTAMP

Qwen Running: $QWEN_RUNNING
Qwen PID: $QWEN_PID
Engine: $ENGINE_EXISTS
Ledger: $LEDGER_EXISTS

Last Execution:
$LEDGER_HEAD
TXT

# --- EXPORT ---
cp "$FREEZE_DIR/HANDOVER.json" "$ANDROID_DIR/HANDOVER_$(basename $FREEZE_DIR).json" 2>/dev/null || true
cp "$FREEZE_DIR/HANDOVER.txt" "$ANDROID_DIR/HANDOVER_$(basename $FREEZE_DIR).txt" 2>/dev/null || true

echo "[HANDOVER] saved to $FREEZE_DIR"
echo "[HANDOVER] exported to $ANDROID_DIR"

echo "===================================="
echo "HANDOVER V3 COMPLETE"
echo "===================================="
