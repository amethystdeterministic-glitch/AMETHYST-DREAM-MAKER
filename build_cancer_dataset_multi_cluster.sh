#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "BUILDING MULTI-CLUSTER CANCER DATASET"
echo "===================================="

DATA_DIR="$HOME/repos/odin_os/datasets/cancer_multi"
mkdir -p "$DATA_DIR"

OUT="$DATA_DIR/cancer_multi_10k.csv"

python3 - <<PYTHON
import numpy as np
import pandas as pd

np.random.seed(42)

rows_per_cluster = 3333

def make_cluster(mean_shift):
    base = np.random.normal(loc=mean_shift, scale=1.0, size=(rows_per_cluster, 10))
    return base

# 3 distinct clusters
cluster_1 = make_cluster(2.0)   # low-mid values
cluster_2 = make_cluster(6.0)   # higher values
cluster_3 = make_cluster(10.0)  # high values

data = np.vstack([cluster_1, cluster_2, cluster_3])

df = pd.DataFrame(data, columns=[f"feature_{i+1}" for i in range(10)])

df.to_csv("$OUT", index=False)

print("Generated:", len(df), "rows")
PYTHON

echo "[STEP] Dataset ready → $OUT"
echo "[STEP] Preview:"
head -n 5 "$OUT"

echo "===================================="
echo "[SUCCESS] MULTI-CLUSTER DATASET READY"
echo "===================================="
