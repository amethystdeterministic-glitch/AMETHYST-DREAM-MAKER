import numpy as np
import pandas as pd
import os

OUT = os.path.expanduser("~/data/brca_datasets/million.tsv")
os.makedirs(os.path.dirname(OUT), exist_ok=True)

n = 1_000_000

np.random.seed(76)

g1 = np.random.normal(0,1,n)
g2 = np.random.normal(0,1,n)

risk = g1 + g2
time = 150 - (risk * 20) + np.random.normal(0,10,n)
event = (risk > np.median(risk)).astype(int)

df = pd.DataFrame({
    "SAMPLE_ID":[f"S{i}" for i in range(n)],
    "GENE1":g1,
    "GENE2":g2,
    "time":time,
    "event":event
})

df.to_csv(OUT, sep="\t", index=False)

print("[DONE] 1M dataset created:", OUT)
