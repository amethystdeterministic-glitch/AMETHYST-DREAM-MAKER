import pandas as pd
import sys, os

input_file = sys.argv[1]
output_file = sys.argv[2]

df = pd.read_csv(input_file, sep="\t")

# Basic cleanup
df.columns = [c.strip().upper() for c in df.columns]

# Ensure sample_id exists
if "SAMPLE_ID" not in df.columns:
    df.insert(0, "SAMPLE_ID", [f"S{i}" for i in range(len(df))])

df.to_csv(output_file, sep="\t", index=False)

print("[GEO INGEST COMPLETE]", output_file)
