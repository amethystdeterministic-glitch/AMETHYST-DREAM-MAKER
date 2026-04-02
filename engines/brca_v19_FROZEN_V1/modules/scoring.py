import numpy as np
import pandas as pd

def compute_scores(df, genes):
    df = df.copy()

    present = [g for g in genes if g in df.columns]

    if len(present) < 5:
        raise ValueError("Too few genes present")

    sub = df[present]

    z = (sub - sub.mean()) / (sub.std(ddof=0) + 1e-9)
    score = np.abs(z).sum(axis=1)

    return score, present
