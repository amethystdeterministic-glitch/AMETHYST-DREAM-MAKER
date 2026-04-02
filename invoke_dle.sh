#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "DLE — INVOKE (DETERMINISTIC)"
echo "===================================="

INPUT_FILE="$1"
SOURCE_LANG="${2:-en}"
TARGET_LANG="${3:-cy}"

if [ -z "$INPUT_FILE" ]; then
  echo "[ERROR] input file required"
  exit 1
fi

OUTPUT_DIR=~/repos/odin_os/artifacts/dle_outputs
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
OUT_FILE="$OUTPUT_DIR/dle_output_${TIMESTAMP}.json"

echo "[STEP] invoking ODIN core translation..."

echo "{
  \"status\": \"stub\",
  \"input\": \"$INPUT_FILE\",
  \"source\": \"$SOURCE_LANG\",
  \"target\": \"$TARGET_LANG\"
}" > "$OUT_FILE"

echo "[OK] output: $OUT_FILE"
echo "===================================="

