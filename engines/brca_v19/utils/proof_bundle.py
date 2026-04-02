import os, json
from utils.hash_utils import file_sha256

def generate_proof(root):

    proof = {
        "run_root": root,
        "files": []
    }

    for dirpath, _, files in os.walk(root):
        for f in files:
            path = os.path.join(dirpath, f)

            try:
                h = file_sha256(path)
                proof["files"].append({
                    "path": path.replace(root,""),
                    "sha256": h
                })
            except:
                continue

    out = f"{root}/FREEZE/proof_bundle.json"

    os.makedirs(f"{root}/FREEZE", exist_ok=True)

    with open(out,"w") as f:
        json.dump(proof,f,indent=2)

    print("[PROOF] GENERATED:", out)
