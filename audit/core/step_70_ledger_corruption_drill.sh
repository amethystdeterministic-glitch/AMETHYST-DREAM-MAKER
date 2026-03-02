#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/70_ledger_corruption_drill.txt"

BIN="target/release/odin_cli"
echo "[STEP 70] Ledger corruption drill" | tee "$LOG"

# Ensure baseline exists
"$BIN" verify >/dev/null 2>&1 || true

LEDGER_PATH="$(ODIN_LEDGER_PATH="${ODIN_LEDGER_PATH:-}" $BIN verify | grep -oE '"ledger_path"\s*:\s*"[^"]+"' | sed -E 's/.*"ledger_path"\s*:\s*"([^"]+)".*/\1/' || true)"
if [[ -z "${LEDGER_PATH:-}" ]]; then
  LEDGER_PATH="$HOME/.odin/ledger/ledger.jsonl"
fi

if [[ ! -f "$LEDGER_PATH" ]]; then
  echo "[FAIL] Ledger missing at $LEDGER_PATH" | tee -a "$LOG"
  exit 1
fi

cp "$LEDGER_PATH" "$LEDGER_PATH.bak"

echo '{"corrupt":true,"note":"injected"}' >> "$LEDGER_PATH"

# verify should fail now (signature parse/verify should break)
set +e
"$BIN" verify >/dev/null 2>&1
rc=$?
set -e

mv "$LEDGER_PATH.bak" "$LEDGER_PATH"

if [[ $rc -eq 0 ]]; then
  echo "[FAIL] verify unexpectedly succeeded after corruption" | tee -a "$LOG"
  exit 1
fi

echo "[PASS] corruption detected (verify failed), ledger restored" | tee -a "$LOG"
