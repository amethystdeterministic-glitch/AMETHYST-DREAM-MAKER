import json, os

REG = os.path.expanduser("~/repos/odin_os/engines/brca_v19/registry/registry.json")

with open(REG) as f:
    reg = json.load(f)

for d in reg["datasets"]:
    print(f"{d['dataset_id']} → {d['version']} → {d['sha256'][:12]}")
