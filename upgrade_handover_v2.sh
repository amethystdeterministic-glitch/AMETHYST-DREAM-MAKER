#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
FREEZE_DIR="$ROOT/artifacts/freeze/$(date -u +%Y%m%dT%H%M%SZ)"
ANDROID_DIR="/storage/emulated/0/Download/ODIN_FREEZE"

mkdir -p "$FREEZE_DIR"
mkdir -p "$ANDROID_DIR"

echo "===================================="
echo "ODIN HANDOVER V2 GENERATION"
echo "===================================="

# --- BASIC CONTEXT ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- PROCESS SCAN ---
QWEN_RUNNING="false"
QWEN_PID=""

if pgrep -f "llama-server" > /dev/null; then
  QWEN_RUNNING="true"
  QWEN_PID=$(pgrep -f "llama-server" | head -n 1)
fi

# --- FILE CHECKS ---
ENGINE_EXISTS="false"
LEDGER_EXISTS="false"

[ -f "$ROOT/pilgrim_clean.sh" ] && ENGINE_EXISTS="true"
[ -f "$ROOT/ledger.jsonl" ] && LEDGER_EXISTS="true"

# --- LEDGER HEAD ---
LEDGER_HEAD=$(tail -n 1 "$ROOT/ledger.jsonl" 2>/dev/null || echo "{}")

# --- DIRECTORY SNAPSHOT ---
TREE=$(ls -R "$ROOT" 2>/dev/null | head -n 200)

# --- SYSTEM SUMMARY ---
cat <<JSON > "$FREEZE_DIR/HANDOVER.json"
{
  "timestamp": "$TIMESTAMP",

  "system": {
    "name": "ODIN / Pilgrim",
    "status": "GREEN",
    "mode": "deterministic_enforcement_runtime"
  },

  "runtime": {
    "qwen_running": $QWEN_RUNNING,
    "qwen_pid": "$QWEN_PID",
    "engine_present": $ENGINE_EXISTS,
    "ledger_present": $LEDGER_EXISTS
  },

  "last_execution": $LEDGER_HEAD,

  "capabilities": [
    "deterministic_enforcement",
    "proof_generation",
    "ledger_append_only",
    "chain_integrity",
    "reject_unauthorised_actions"
  ],

  "architecture": {
    "entry_point": "pilgrim_clean.sh",
    "brain": "qwen via llama.cpp",
    "ledger": "jsonl append-only with chaining"
  },

  "filesystem_snapshot": "$TREE",

  "resume": {
    "command": "~/repos/odin_os/odin_on",
    "test": "bash pilgrim_clean.sh \"deploy engine test\" --dry-run",
    "next_step": "authority_layer"
  }
}
JSON

# --- HUMAN SUMMARY ---
cat <<TXT > "$FREEZE_DIR/HANDOVER.txt"
ODIN HANDOVER SUMMARY
=====================

Timestamp: $TIMESTAMP

SYSTEM:
- Status: GREEN
- Mode: Deterministic Enforcement Runtime

RUNTIME:
- Qwen Running: $QWEN_RUNNING
- Qwen PID: $QWEN_PID
- Engine Present: $ENGINE_EXISTS
- Ledger Present: $LEDGER_EXISTS

LAST EXECUTION:
$LEDGER_HEAD

NEXT:
- Implement authority layer
- Maintain deterministic lifecycle

COMMANDS:
- Start: odin_on
- Test: bash pilgrim_clean.sh "deploy engine test" --dry-run
TXT

# --- COPY KEY FILES ---
cp "$ROOT/ledger.jsonl" "$FREEZE_DIR/" 2>/dev/null || true
cp "$ROOT/engine_state.json" "$FREEZE_DIR/" 2>/dev/null || true

# --- ANDROID EXPORT ---
cp "$FREEZE_DIR/HANDOVER.json" "$ANDROID_DIR/HANDOVER_$(basename $FREEZE_DIR).json"
cp "$FREEZE_DIR/HANDOVER.txt" "$ANDROID_DIR/HANDOVER_$(basename $FREEZE_DIR).txt"

echo "[HANDOVER] saved to $FREEZE_DIR"
echo "[HANDOVER] exported to $ANDROID_DIR"

echo "===================================="
echo "HANDOVER V2 COMPLETE"
echo "===================================="
