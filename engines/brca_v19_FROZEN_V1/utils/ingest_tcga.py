import pandas as pd
import sys

expr_file = sys.argv[1]
clinical_file = sys.argv[2]
output_file = sys.argv[3]

expr = pd.read_csv(expr_file, sep="\t", index_col=0).T
clin = pd.read_csv(clinical_file, sep="\t")

# Basic merge assumption
clin = clin.rename(columns={
    "sample": "SAMPLE_ID",
    "OS.time": "time",
    "OS": "event"
})

df = expr.copy()
df["SAMPLE_ID"] = df.index

df = df.merge(clin[["SAMPLE_ID","time","event"]], on="SAMPLE_ID", how="left")

df.to_csv(output_file, sep="\t", index=False)

print("[TCGA INGEST COMPLETE]", output_file)
