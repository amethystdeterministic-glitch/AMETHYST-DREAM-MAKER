#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
OUT="audit/core/out"
mkdir -p "$OUT"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

echo "[RUN_ALL] 시작 $(ts)" | tee "$OUT/_run_all.log"

# Run steps (each step should be idempotent)
bash audit/core/step_10_detect_binaries.sh
bash audit/core/step_20_build_release.sh
bash audit/core/step_30_scan_todos.sh
bash audit/core/step_40_detect_paths.sh
bash audit/core/step_50_verify_baseline.sh
bash audit/core/step_60_replay_check.sh
bash audit/core/step_70_ledger_corruption_drill.sh
bash audit/core/step_80_authority_missing_drill.sh
bash audit/core/step_90_duplicate_finalize_stress.sh
bash audit/core/step_99_generate_report.sh

echo "[RUN_ALL] 완료 $(ts)" | tee -a "$OUT/_run_all.log"
echo "[RUN_ALL] REPORT: $OUT/REPORT.md"
