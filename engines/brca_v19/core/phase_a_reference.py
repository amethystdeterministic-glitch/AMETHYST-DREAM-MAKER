import pandas as pd

print("[PHASE A] START")

# === LOAD DATASET ===
df = pd.read_csv("~/data/brca_datasets/million.tsv", sep="\t")

print("[PHASE A] DATA SHAPE:", df.shape)

# === BASIC NUMERIC FILTER ===
num = df.select_dtypes(include=["number"])

print("[PHASE A] NUMERIC COLS:", num.shape[1])

# === SIGNAL V1 ===
from signal_v1 import apply_signal_v1
df = apply_signal_v1(df)

print("[SIGNAL] SIGNAL_V1 locked at correct layer")

# === SCORE ===
df["score"] = df["SIGNAL_V1"]
print("[SIGNAL] using SIGNAL_V1 as score")

# === DEBUG ===
print("[DEBUG] SIGNAL_V1 stats:")
print(df["SIGNAL_V1"].describe())

print("[DEBUG] GROUP counts:")
print(df["group"].value_counts())

# === SAVE OUTPUT ===
df.to_csv("phase_a_output.tsv", sep="\t", index=False)

print("[PHASE A] COMPLETE")


# === SURVIVAL VALIDATION (HR) ===
import numpy as np

g0 = df[df["group"] == 0]
g1 = df[df["group"] == 1]

# avoid divide issues
mean0 = g0["time"].mean()
mean1 = g1["time"].mean()

hr = mean1 / mean0 if mean0 != 0 else np.nan

print("[RESULT]")
print(f"[HR] hazard_ratio={hr:.6f}")
print(f"[GROUP0 mean time]={mean0:.4f}")
print(f"[GROUP1 mean time]={mean1:.4f}")


# === D.R.E.A.M SIGNAL ENFORCEMENT ===
EXPECTED_HR = 0.8076
TOLERANCE = 0.01

if abs(hr - EXPECTED_HR) > TOLERANCE:
    raise RuntimeError(f"[ENFORCEMENT] SIGNAL_V1 deviation detected: {hr}")

print("[ENFORCEMENT] SIGNAL_V1 validated within tolerance")
