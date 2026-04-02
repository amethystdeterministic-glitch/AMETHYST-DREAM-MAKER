import pandas as pd
import sys

f = sys.argv[1]

df = pd.read_csv(f, sep="\t")

errors = []

if "SAMPLE_ID" not in df.columns:
    errors.append("missing SAMPLE_ID")

if len(df) < 50:
    errors.append("too few samples")

if df.var().sum() == 0:
    errors.append("no variance")

if errors:
    print("[INVALID]", f, errors)
else:
    print("[VALID]", f)
