import json, time, os

def append_event(root, name, event):
    path = f"{root}/LEDGER/{name}.jsonl"

    event["ts"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

    os.makedirs(os.path.dirname(path), exist_ok=True)

    with open(path, "a") as f:
        f.write(json.dumps(event) + "\n")
