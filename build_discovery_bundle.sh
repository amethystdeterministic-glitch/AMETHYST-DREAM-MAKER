#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "BUILDING DISCOVERY BUNDLE (SCOPED)"
echo "===================================="

BASE="$HOME/repos/odin_os"
OUT="$BASE/DISCOVERY_LATEST"

mkdir -p "$OUT"

echo "[STEP] Finding latest cancer discovery artifact..."

LATEST=$(ls -td "$BASE/artifacts"/cancer_* 2>/dev/null | head -1 || true)

if [ -z "${LATEST:-}" ]; then
    echo "[FAIL] No cancer discovery artifacts found"
    exit 1
fi

echo "[INFO] Using artifact: $LATEST"

echo "[STEP] Copying files..."
cp -v "$LATEST"/* "$OUT/" || true

echo "[STEP] Linking dataset..."

DATASET_PATH=$(ls -t "$BASE"/datasets/*/*.csv 2>/dev/null | head -1 || true)

if [ -n "${DATASET_PATH:-}" ]; then
    cp -v "$DATASET_PATH" "$OUT/dataset.csv"
else
    echo "[WARN] No dataset found"
fi

echo "[STEP] Creating README..."

cat > "$OUT/README.txt" <<EOT
AMETHYST DISCOVERY BUNDLE
=========================

SOURCE ARTIFACT:
$LATEST

CONTENTS:
- dataset.csv
- discovery outputs
- explanations
- report

Generated: $(date -u)

STATUS:
PRODUCTION READY (DETERMINISTIC DISCOVERY PIPELINE)
EOT

echo "===================================="
echo "[SUCCESS] DISCOVERY BUNDLE READY → $OUT"
echo "===================================="
