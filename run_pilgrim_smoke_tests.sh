#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[SMOKE] startup"
"$SCRIPT" startup

echo "[SMOKE] version"
"$SCRIPT" version

echo "[SMOKE] banner"
"$SCRIPT" banner >/dev/null

echo "[SMOKE] dry-run deploy"
"$SCRIPT" "deploy engine smoke_alpha" --dry-run | grep -q SIMULATED

echo "[SMOKE] real deploy"
"$SCRIPT" "deploy engine smoke_alpha" | grep -q ENFORCED

echo "[SMOKE] status"
"$SCRIPT" "check system status" | grep -q OK

echo "[SMOKE] delete blocked (no auth)"
"$SCRIPT" "delete all engines" | grep -q requires_authority

echo "[SMOKE] delete allowed (ROOT)"
"$SCRIPT" "delete all engines" ROOT | grep -q ENFORCED

echo "[SMOKE] snapshot create"
"$SCRIPT" snapshot:create >/dev/null

echo "[SMOKE] health"
"$SCRIPT" health >/dev/null

echo "[SMOKE] ledger"
"$SCRIPT" ledger >/dev/null

echo "[SMOKE] verify install"
"$SCRIPT" verify:install

echo "[SMOKE] PASS"
