import json, os, sys, hashlib, time

REG = os.path.expanduser("~/repos/odin_os/engines/brca_v19/registry/registry.json")

def hash_file(path):
    h = hashlib.sha256()
    with open(path,'rb') as f:
        h.update(f.read())
    return h.hexdigest()

dataset_path = os.path.expanduser(sys.argv[1])
dataset_id   = os.path.basename(dataset_path).replace(".tsv","")

with open(REG) as f:
    reg = json.load(f)

entry = {
    "dataset_id": dataset_id,
    "path": dataset_path,
    "sha256": hash_file(dataset_path),
    "registered_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "version": "v1"
}

reg["datasets"].append(entry)

with open(REG,"w") as f:
    json.dump(reg,f,indent=2)

print("[REGISTERED]", dataset_id)
