#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[RETEST] syntax check"
bash -n "$SCRIPT"

echo "[RETEST] startup"
"$SCRIPT" startup >/dev/null

echo "[RETEST] Qwen connectivity"
curl -s http://localhost:8081/completion >/dev/null || {
  echo "[RETEST] Qwen not reachable"
  exit 1
}

echo "[RETEST] dry-run deploy"
"$SCRIPT" "deploy engine retest_alpha" --dry-run | grep -q SIMULATED

echo "[RETEST] real deploy"
"$SCRIPT" "deploy engine retest_alpha" | grep -q ENFORCED

echo "[RETEST] status"
"$SCRIPT" "check system status" | grep -q OK

echo "[RETEST] delete blocked"
"$SCRIPT" "delete all engines" | grep -q requires_authority

echo "[RETEST] delete allowed (ROOT)"
"$SCRIPT" "delete all engines" ROOT | grep -q ENFORCED

echo "[RETEST] PASS"
