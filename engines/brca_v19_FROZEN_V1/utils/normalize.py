import pandas as pd
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

df = pd.read_csv(input_file, sep="\t")

meta_cols = ["SAMPLE_ID","time","event"]
genes = [c for c in df.columns if c not in meta_cols]

sub = df[genes]

z = (sub - sub.mean()) / (sub.std(ddof=0) + 1e-9)

out = pd.concat([df[meta_cols], z], axis=1)

out.to_csv(output_file, sep="\t", index=False)

print("[NORMALIZED]", output_file)
