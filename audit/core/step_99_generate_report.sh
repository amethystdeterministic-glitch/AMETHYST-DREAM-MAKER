#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
OUT="audit/core/out"
REPORT="$OUT/REPORT.md"

echo "# ODIN Core Freeze Audit Report" > "$REPORT"
echo "" >> "$REPORT"
echo "Generated: $(date -u)" >> "$REPORT"
echo "" >> "$REPORT"

for f in "$OUT"/*.txt; do
  echo "## $(basename "$f")" >> "$REPORT"
  echo '```' >> "$REPORT"
  cat "$f" >> "$REPORT"
  echo '```' >> "$REPORT"
  echo "" >> "$REPORT"
done

echo "[STEP 99] Report generated at $REPORT"
