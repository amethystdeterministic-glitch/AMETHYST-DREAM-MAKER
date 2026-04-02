import json, os, sys, hashlib

REG = os.path.expanduser("~/repos/odin_os/engines/brca_v19/registry/registry.json")

def hash_file(path):
    h = hashlib.sha256()
    with open(path,'rb') as f:
        h.update(f.read())
    return h.hexdigest()

dataset_path = os.path.expanduser(sys.argv[1])

h = hash_file(dataset_path)

with open(REG) as f:
    reg = json.load(f)

matches = [d for d in reg["datasets"] if d["sha256"] == h]

if matches:
    print("[VALID] Dataset matches registry:", matches[0]["dataset_id"], matches[0]["version"])
else:
    print("[WARNING] Dataset not registered")
