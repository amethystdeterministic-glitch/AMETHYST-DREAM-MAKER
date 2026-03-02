#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="audit/core/out"
mkdir -p "$OUT"

BIN="target/release/odin_cli"
LOG="$OUT/10_detect_binaries.txt"

echo "[STEP 10] Detect canonical binary" | tee "$LOG"

if [[ -x "$BIN" ]]; then
    echo "[OK] Found executable: $BIN" | tee -a "$LOG"
    exit 0
else
    echo "[FAIL] Missing required binary: $BIN" | tee -a "$LOG"
    exit 1
fi
