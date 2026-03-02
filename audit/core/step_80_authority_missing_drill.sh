#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/80_authority_missing_drill.txt"

BIN="target/release/odin_cli"
echo "[STEP 80] Authority missing drill" | tee "$LOG"

# Ensure baseline valid
"$BIN" verify >/dev/null 2>&1 || {
  echo "[FAIL] baseline verify failed before drill" | tee -a "$LOG"
  exit 1
}

KEY_PATH="$HOME/.odin/keys/authority.key"
PUB_PATH="$HOME/.odin/keys/authority.pub"

if [[ ! -f "$KEY_PATH" || ! -f "$PUB_PATH" ]]; then
  echo "[FAIL] expected keypair at default paths not found" | tee -a "$LOG"
  exit 1
fi

# Remove keys
mv "$KEY_PATH" "$KEY_PATH.bak"
mv "$PUB_PATH" "$PUB_PATH.bak"

# Verify should FAIL (fail-closed)
set +e
"$BIN" verify >/dev/null 2>&1
rc=$?
set -e

# Restore keys
mv "$KEY_PATH.bak" "$KEY_PATH"
mv "$PUB_PATH.bak" "$PUB_PATH"

if [[ $rc -eq 0 ]]; then
  echo "[FAIL] verify unexpectedly succeeded without authority key" | tee -a "$LOG"
  exit 1
fi

echo "[PASS] missing authority correctly caused verify to fail (fail-closed)" | tee -a "$LOG"
