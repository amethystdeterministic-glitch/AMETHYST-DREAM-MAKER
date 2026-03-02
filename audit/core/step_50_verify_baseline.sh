#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/50_verify_baseline.txt"

BIN="target/release/odin_cli"

echo "[STEP 50] Verify baseline contract" | tee "$LOG"

if [[ ! -x "$BIN" ]]; then
    echo "[FAIL] Canonical binary missing: $BIN" | tee -a "$LOG"
    exit 1
fi

echo "[TRY] $BIN verify" | tee -a "$LOG"
"$BIN" verify >>"$LOG" 2>&1
echo "[PASS] Baseline verification complete" | tee -a "$LOG"
