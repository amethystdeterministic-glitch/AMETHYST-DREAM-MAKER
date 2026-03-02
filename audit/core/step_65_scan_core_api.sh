#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
OUT="audit/core/out"
mkdir -p "$OUT"

LOG="$OUT/65_core_api_scan.txt"
: > "$LOG"

echo "[STEP 65] Scan odin_core for existing verify/proof surfaces" | tee -a "$LOG"
echo "" >> "$LOG"

if command -v rg >/dev/null 2>&1; then
  echo "[RG] export_proof / proof / verify / receipt / ledger / authority" | tee -a "$LOG"
  rg -n "export_proof|proof|verify|receipt|ledger|authority|boot" core/src >> "$LOG" 2>/dev/null || true
else
  echo "[GREP] export_proof / proof / verify / receipt / ledger / authority" | tee -a "$LOG"
  grep -RIn -E "export_proof|proof|verify|receipt|ledger|authority|boot" core/src >> "$LOG" 2>/dev/null || true
fi

echo "" >> "$LOG"
echo "[DONE] Wrote $LOG"
