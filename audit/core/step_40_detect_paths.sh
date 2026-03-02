#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/40_detect_paths.txt"

echo "[STEP 40] Detect critical paths" | tee "$LOG"

if [[ -x "target/release/odin_cli" ]]; then
    echo "[OK] Canonical binary present: target/release/odin_cli" | tee -a "$LOG"
else
    echo "[FAIL] Missing canonical binary: target/release/odin_cli" | tee -a "$LOG"
    exit 1
fi

if [[ -d "audit/core" ]]; then
    echo "[OK] Audit directory present" | tee -a "$LOG"
else
    echo "[FAIL] Audit directory missing" | tee -a "$LOG"
    exit 1
fi

echo "[PASS] Path detection complete" | tee -a "$LOG"
exit 0
