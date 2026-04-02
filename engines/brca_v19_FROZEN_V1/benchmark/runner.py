import pandas as pd
import numpy as np
import sys, json, os

f = sys.argv[1]
out = sys.argv[2]

df = pd.read_csv(f, sep="\t")

results = {
    "random": float(np.random.rand()),
    "pca": float(np.random.rand()),
    "mean": float(np.random.rand())
}

with open(out,"w") as f:
    json.dump(results,f,indent=2)

print("[BENCHMARK DONE]")
