import requests
import json
import time

LEDGER_PATH = "/data/data/com.termux/files/home/odin_runtime/ledger/spark_events.jsonl"
PILGRIM_URL = "http://127.0.0.1:8083/completion"

def ledger_write(event):
    try:
        with open(LEDGER_PATH, "a") as f:
            f.write(json.dumps(event) + "\n")
    except:
        pass

def spark_exec(input_text):

    payload = {
        "prompt": "You are Pilgrim AI. Respond clearly and deterministically.\n\nUser: " + input_text + "\nPilgrim:",
        "n_predict": 64,
        "temperature": 0.1
    }

    try:
        r = requests.post(PILGRIM_URL, json=payload, timeout=30)
        data = r.json()

        output = data.get("content", "").strip()
        if not output:
            output = "No response"

        event = {
            "ts": int(time.time()),
            "input": input_text,
            "engine": "pilgrim_core",
            "output_preview": output[:120]
        }

        ledger_write(event)

        return "[PILGRIM]: " + output

    except Exception as e:
        return "[ERROR]: " + str(e)
