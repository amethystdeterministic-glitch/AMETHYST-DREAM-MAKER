#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FINAL VERIFY] syntax"
bash -n "$SCRIPT"

echo "[FINAL VERIFY] startup"
"$SCRIPT" startup >/dev/null

echo "[FINAL VERIFY] dry-run"
"$SCRIPT" "deploy engine final_check" --dry-run | grep -q SIMULATED

echo "[FINAL VERIFY] deploy"
"$SCRIPT" "deploy engine final_check" | grep -q ENFORCED

echo "[FINAL VERIFY] status"
"$SCRIPT" "check system status" | grep -q OK

echo "[FINAL VERIFY] ROOT delete"
"$SCRIPT" "delete all engines" ROOT | grep -q ENFORCED

echo "[FINAL VERIFY] PASS"
