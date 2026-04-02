#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/data/data/com.termux/files/home/repos/odin_os"

echo "===================================="
echo "BREAST CANCER — OPEN DISCOVERY MODE"
echo "AMETHYST cOS"
echo "===================================="

TS="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$BASE_DIR/artifacts/cancer_open_$TS"

mkdir -p "$RUN_DIR"

DATASET="$BASE_DIR/datasets/cancer/breast_cancer.csv"

EN_FILE="$RUN_DIR/discovery_en.txt"
CY_FILE="$RUN_DIR/discovery_cy.txt"

echo "[STEP] Running open deterministic discovery..."

awk -F',' '
{
  for (i=2; i<=NF; i++) {
    val=$i+0

    sum[i]+=val
    sumsq[i]+=val*val
    count[i]++

    # simple co-movement with next feature
    if (i < NF) {
      nextval=$(i+1)+0
      cross[i]+=val*nextval
    }
  }
}
END {
  print "DETERMINISTIC OPEN DISCOVERY"
  print "----------------------------"

  for (i=2; i<=NF; i++) {
    mean = sum[i]/count[i]
    variance = (sumsq[i]/count[i]) - (mean*mean)

    printf "feature_%d | variance=%.6f | mean=%.6f\n", i-1, variance, mean
  }

  print ""
  print "FEATURE CO-MOVEMENT SIGNALS"
  print "---------------------------"

  for (i=2; i<NF; i++) {
    avg_cross = cross[i]/count[i]
    printf "feature_%d <-> feature_%d | co_signal=%.6f\n", i-1, i, avg_cross
  }
}
' "$DATASET" \
| sort -t'|' -k2 -nr \
| head -n 25 \
> "$EN_FILE"

echo "[STEP] Open discovery generated"

# DLE (current mode)
cp "$EN_FILE" "$CY_FILE"

echo "[ENGINE:DLE] SUCCESS (fallback mirror)"

sha256sum "$EN_FILE" > "$RUN_DIR/en.hash"
sha256sum "$CY_FILE" > "$RUN_DIR/cy.hash"

echo "===================================="
echo "[SUCCESS] OPEN DISCOVERY COMPLETE"
echo "$RUN_DIR"
echo "===================================="
