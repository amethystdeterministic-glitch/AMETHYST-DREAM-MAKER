#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[VERIFY] syntax check"
bash -n "$SCRIPT"

echo "[VERIFY] startup"
"$SCRIPT" startup >/dev/null

echo "[VERIFY] dry-run"
"$SCRIPT" "deploy engine verify_fix" --dry-run | grep -q SIMULATED

echo "[VERIFY] real deploy"
"$SCRIPT" "deploy engine verify_fix" | grep -q ENFORCED

echo "[VERIFY] status"
"$SCRIPT" "check system status" | grep -q OK

echo "[VERIFY] PASS"
