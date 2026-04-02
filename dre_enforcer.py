import json
import hashlib
import time

ALLOWED_ACTIONS = {"deploy", "test", "status"}

def normalize(payload):
    if payload is None:
        return "none"
    return str(payload).replace(" ", "_")

def enforce(actions):
    enforced = []
    rejected = []

    for x in actions:
        action = x.get("action")
        payload = normalize(x.get("payload"))

        if action not in ALLOWED_ACTIONS:
            rejected.append({
                "action": action,
                "payload": payload,
                "reason": "not_allowed"
            })
            continue

        enforced.append({
            "action": action,
            "payload": payload
        })

    return enforced, rejected


def proof(action, payload):
    raw = f"{action}:{payload}:{int(time.time())}"
    return hashlib.sha256(raw.encode()).hexdigest()


def execute(actions, dry_run=True):
    results = []

    for x in actions:
        action = x["action"]
        payload = x["payload"]

        if dry_run:
            results.append({
                "action": action,
                "payload": payload,
                "status": "SIMULATED"
            })
        else:
            results.append({
                "action": action,
                "payload": payload,
                "status": "ENFORCED",
                "proof": proof(action, payload)
            })

    return results
