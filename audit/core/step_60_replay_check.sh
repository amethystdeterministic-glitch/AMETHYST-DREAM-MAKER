#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/60_replay_check.txt"

BIN="target/release/odin_cli"

echo "[STEP 60] Replay determinism check" | tee "$LOG"

if [[ ! -x "$BIN" ]]; then
    echo "[FAIL] Canonical binary missing: $BIN" | tee -a "$LOG"
    exit 1
fi

HASH1="$("$BIN" verify | sha256sum | awk '{print $1}')"
HASH2="$("$BIN" verify | sha256sum | awk '{print $1}')"

echo "HASH1=$HASH1" | tee -a "$LOG"
echo "HASH2=$HASH2" | tee -a "$LOG"

if [[ "$HASH1" == "$HASH2" ]]; then
    echo "[PASS] Deterministic replay confirmed" | tee -a "$LOG"
    exit 0
else
    echo "[FAIL] Replay hash mismatch" | tee -a "$LOG"
    exit 1
fi
