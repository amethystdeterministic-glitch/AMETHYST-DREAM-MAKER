import pandas as pd

def run_dataset(path, root, dataset_id):
    df = pd.read_csv(path, sep="\t")
    return {
        "dataset": dataset_id,
        "rows": len(df),
        "status": "OK"
    }
