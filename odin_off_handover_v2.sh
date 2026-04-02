#!/data/data/com.termux/files/usr/bin/bash

OUT_DIR=~/repos/odin_os/artifacts/handover
STAMP=$(date -u +"%Y%m%dT%H%M%SZ")
OUT_FILE="$OUT_DIR/ODIN_OFF_${STAMP}.txt"

mkdir -p "$OUT_DIR"

echo "============================================================" > "$OUT_FILE"
echo "ODIN OFF HANDOVER — FULL SYSTEM STATE" >> "$OUT_FILE"
echo "TIMESTAMP: $STAMP" >> "$OUT_FILE"
echo "STATE: CANONICAL" >> "$OUT_FILE"
echo "============================================================" >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "## SYSTEM SNAPSHOT" >> "$OUT_FILE"
ps aux | grep -E "llama|captain|enforcement" >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "## ARTIFACT INVENTORY" >> "$OUT_FILE"
ls -R ~/repos/odin_os/artifacts >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "## DISCOVERY REGISTER" >> "$OUT_FILE"
ls ~/repos/odin_os/artifacts/discoveries >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "## HANDOVER DIRECTIVE" >> "$OUT_FILE"
echo "YOU ARE ENTERING ODIN STATE:" >> "$OUT_FILE"
echo "- Discovery Protocol: ACTIVE" >> "$OUT_FILE"
echo "- Artifacts Root: ~/repos/odin_os/artifacts/" >> "$OUT_FILE"
echo "- Latest Discovery:" >> "$OUT_FILE"
ls -t ~/repos/odin_os/artifacts/discoveries | head -n 1 >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "## DISCOVERY PROTOCOL" >> "$OUT_FILE"
cat ~/repos/odin_os/artifacts/handover/ODIN_HANDOVER_DISCOVERY_V1.txt >> "$OUT_FILE"

echo "" >> "$OUT_FILE"
echo "============================================================" >> "$OUT_FILE"
echo "ODIN OFF COMPLETE" >> "$OUT_FILE"
echo "============================================================" >> "$OUT_FILE"

echo "[OK] Handover written to $OUT_FILE"
