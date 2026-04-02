#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "BREAST CANCER DATASET SETUP"
echo "===================================="

DATA_DIR="$HOME/repos/odin_os/datasets/cancer_real"
mkdir -p "$DATA_DIR"

FILE="$DATA_DIR/breast_cancer_wisconsin.csv"

echo "[STEP] Downloading dataset..."

curl -L -o "$FILE" \
https://raw.githubusercontent.com/plotly/datasets/master/data.csv

echo "[STEP] Dataset stored at $FILE"

echo "[STEP] Preview:"
head -n 5 "$FILE"

echo "===================================="
echo "[SUCCESS] DATASET READY"
echo "===================================="
