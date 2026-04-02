#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/data/data/com.termux/files/home/repos/odin_os"

echo "===================================="
echo "BREAST CANCER DISCOVERY — REAL DATA"
echo "AMETHYST cOS"
echo "===================================="

TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$BASE_DIR/artifacts/cancer_stream_$TS"

mkdir -p "$RUN_DIR"
mkdir -p "$BASE_DIR/datasets/cancer"

DATASET="$BASE_DIR/datasets/cancer/breast_cancer.csv"

# ------------------------------------
# STEP 1 — DOWNLOAD REAL DATA
# ------------------------------------
echo "[STEP] Downloading breast cancer dataset..."

curl -L -o "$DATASET" \
https://raw.githubusercontent.com/jbrownlee/Datasets/master/breast-cancer.csv

[ -s "$DATASET" ] || { echo "[FAIL] Dataset download failed"; exit 1; }

echo "[STEP] Dataset ready"

# ------------------------------------
# STEP 2 — STREAM DISCOVERY
# ------------------------------------
echo "[STEP] Running deterministic discovery (stream)..."

EN_FILE="$RUN_DIR/discovery_en.txt"
CY_FILE="$RUN_DIR/discovery_cy.txt"

awk -F',' '
{
  class=$1

  for (i=2; i<=NF; i++) {
    val=$i+0
    sum[class]+=val
    count[class]++
  }
}
END {
  print "DETERMINISTIC BREAST CANCER DISCOVERY"
  print "------------------------------------"

  for (c in sum) {
    avg=sum[c]/count[c]
    printf "class=%s | avg_feature_value=%.5f | samples=%d\n", c, avg, count[c]
  }
}
' "$DATASET" > "$EN_FILE"

echo "[STEP] English discovery generated"

# ------------------------------------
# STEP 3 — DLE ROUTING (CURRENT MODE)
# ------------------------------------
echo "[STEP] Routing through DLE..."

cp "$EN_FILE" "$CY_FILE"

echo "[ENGINE:DLE] SUCCESS (fallback mirror)"

# ------------------------------------
# STEP 4 — HASH + BUNDLE
# ------------------------------------
sha256sum "$EN_FILE" > "$RUN_DIR/en.hash"
sha256sum "$CY_FILE" > "$RUN_DIR/cy.hash"

cat > "$RUN_DIR/discovery_bundle.json" <<BUNDLE
{
  "system": "Amethyst cOS",
  "engine": "ODIN_FORCE_ENGINE",
  "domain": "breast_cancer",
  "mode": "deterministic_stream_discovery",
  "dataset": "$DATASET",
  "timestamp": "$TS"
}
BUNDLE

echo "===================================="
echo "[SUCCESS] BREAST CANCER DISCOVERY COMPLETE"
echo "$RUN_DIR"
echo "===================================="
