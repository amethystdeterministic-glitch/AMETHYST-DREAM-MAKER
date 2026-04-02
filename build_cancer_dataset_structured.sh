#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "BUILDING STRUCTURED MULTI-CLUSTER DATASET"
echo "===================================="

DATA_DIR="$HOME/repos/odin_os/datasets/cancer_structured"
mkdir -p "$DATA_DIR"

OUT="$DATA_DIR/cancer_structured_10k.csv"

python3 - <<PYTHON
import numpy as np
import pandas as pd

np.random.seed(42)

rows = 3333

def cluster(pattern):
    base = np.random.normal(0, 1, (rows, 10))

    for i in pattern:
        base[:, i] += np.random.normal(5, 1, rows)

    return base

# different feature dominance
c1 = cluster([0,1,2])     # features 1–3
c2 = cluster([3,4,5])     # features 4–6
c3 = cluster([6,7,8,9])   # features 7–10

data = np.vstack([c1, c2, c3])

df = pd.DataFrame(data, columns=[f"feature_{i+1}" for i in range(10)])

df.to_csv("$OUT", index=False)

print("Generated:", len(df), "rows")
PYTHON

echo "[STEP] Dataset ready → $OUT"
head -n 5 "$OUT"

echo "===================================="
echo "[SUCCESS] STRUCTURED DATASET READY"
echo "===================================="
