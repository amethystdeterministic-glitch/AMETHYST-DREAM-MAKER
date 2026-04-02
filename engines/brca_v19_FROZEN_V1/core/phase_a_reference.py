import pandas as pd
import numpy as np

dataset = "~/data/brca_datasets/million.tsv"

df = pd.read_csv(dataset, sep="\t")

# 🔥 BREAK THE SIGNAL EARLY (correct position)
df["time"] = np.random.permutation(df["time"].values)

print("[PHASE A] DATA SHAPE:", df.shape)

genes = [c for c in df.columns if c not in ["SAMPLE_ID","time","event"]]

# scoring model under test
df["score"] = df["GENE1"] * 2 - df["GENE2"]

threshold = df["score"].median()
df["group"] = (df["score"] > threshold).astype(int)

print("[SCORING HEAD]")
print(df[["SAMPLE_ID","GENE1","GENE2","score","group"]].head())

g0 = df[df["group"] == 0]["time"].mean()
g1 = df[df["group"] == 1]["time"].mean()

print("[RESULT]")
print("LOW GROUP:", g0)
print("HIGH GROUP:", g1)

hr = g1 / g0 if g0 != 0 else 0
print("HAZARD RATIO:", hr)

if g1 < g0:
    print("SIGNAL: HIGH SCORE WORSE")
else:
    print("SIGNAL: HIGH SCORE BETTER")
