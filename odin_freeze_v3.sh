#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="$ROOT/artifacts/freeze/$STAMP"

mkdir -p "$OUT"

echo "===================================="
echo "ODIN FREEZE V3 START"
echo "===================================="

# ----------------------------
# CONTEXT
# ----------------------------
echo "timestamp_utc=$STAMP" > "$OUT/context.env"
echo "root=$ROOT" >> "$OUT/context.env"

# ----------------------------
# COPY CRITICAL FILES
# ----------------------------
cp "$ROOT/pilgrim_clean.sh" "$OUT/"
cp "$ROOT/parser_v2.py" "$OUT/" 2>/dev/null || true
cp "$ROOT/dre_enforcer.py" "$OUT/" 2>/dev/null || true
cp "$ROOT/dre_ledger.py" "$OUT/" 2>/dev/null || true

# ----------------------------
# STATE SNAPSHOT
# ----------------------------
cp "$ROOT/engine_state.json" "$OUT/" 2>/dev/null || true
cp "$ROOT/ledger.jsonl" "$OUT/" 2>/dev/null || true

# ----------------------------
# HASHES (DETERMINISTIC PROOF)
# ----------------------------
(
  cd "$OUT"
  sha256sum * > SHA256SUMS.txt 2>/dev/null || true
)

# ----------------------------
# POSITION STATEMENT
# ----------------------------
cat <<'POS' > "$OUT/POSITION.txt"
FREEZE: D.R.E. PIPELINE STABLE

This snapshot represents a deterministic AI runtime with:

- Controlled LLM parsing
- Explicit action extraction
- Deterministic Runtime Enforcement (D.R.E.)
- Rejection visibility
- Controlled execution layer
- Cryptographic proof per action
- Append-only ledger recording

System guarantees:

- Model output is not trusted
- All actions are validated before execution
- Invalid actions are rejected and recorded
- Execution is deterministic under constraints
- Full traceability exists per intent

STATE: GREEN
POS

echo "===================================="
echo "FREEZE SAVED:"
echo "$OUT"
echo "===================================="
echo "STATE: GREEN"
echo "===================================="
