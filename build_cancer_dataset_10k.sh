#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "BUILDING 10K BREAST CANCER DATASET"
echo "===================================="

DATA_DIR="$HOME/repos/odin_os/datasets/cancer_10k"
mkdir -p "$DATA_DIR"

BASE="$DATA_DIR/base.csv"
OUT="$DATA_DIR/cancer_10k.csv"

echo "[STEP] Downloading base dataset..."

curl -L -o "$BASE" \
https://raw.githubusercontent.com/selva86/datasets/master/BreastCancer.csv

echo "[STEP] Expanding to 10k rows..."

python3 - <<PYTHON
import pandas as pd
import numpy as np

df = pd.read_csv("$BASE")

# keep only numeric and convert to float
df = df.select_dtypes(include=[np.number]).dropna().astype(float)

rows = 10000
expanded = []

np.random.seed(42)

for i in range(rows):
    row = df.sample(1).copy()

    noise = np.random.normal(0, 0.01, size=row.shape[1])
    row.iloc[0] = row.iloc[0].values + noise

    expanded.append(row)

out = pd.concat(expanded, ignore_index=True)
out.to_csv("$OUT", index=False)

print("Generated:", len(out), "rows")
PYTHON

echo "[SUCCESS] Dataset ready → $OUT"
