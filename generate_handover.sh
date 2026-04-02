#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
OUT_DIR="$ROOT/artifacts/freeze/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT_DIR"

LEDGER="$ROOT/ledger.jsonl"

LAST_ENTRY=$(tail -n 1 "$LEDGER" 2>/dev/null || echo "{}")

cat <<JSON > "$OUT_DIR/HANDOVER.json"
{
  "system": {
    "name": "ODIN / Pilgrim",
    "version": "PILGRIM_ENFORCE_V1_CHAIN_ACTIVE",
    "status": "GREEN"
  },
  "runtime": {
    "qwen_port": 8081,
    "engine": "pilgrim_clean.sh",
    "dry_run": true
  },
  "last_execution": $LAST_ENTRY,
  "capabilities": [
    "deterministic_enforcement",
    "proof_generation",
    "ledger_append_only",
    "chain_integrity_active"
  ],
  "pending": [
    "parser_dedupe_pending",
    "authority_layer_not_started"
  ],
  "resume": {
    "start_command": "odin_on",
    "next_step": "authority_layer"
  }
}
JSON

echo "[HANDOVER] created at $OUT_DIR/HANDOVER.json"
