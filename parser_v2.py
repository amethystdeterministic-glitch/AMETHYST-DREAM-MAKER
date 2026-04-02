import json
import re

ALLOWED = {"deploy", "test", "status"}

def extract_json(raw):
    try:
        start = raw.index('[')
        end = raw.rindex(']') + 1
        return json.loads(raw[start:end])
    except:
        return None

def extract_loose(raw):
    actions = []

    pattern = re.findall(r'(deploy|test|status|hack)\s+([a-zA-Z0-9_\- ]+)', raw)

    for act, payload in pattern:
        actions.append({
            "action": act.strip(),
            "payload": payload.strip()
        })

    return actions

def parse(raw):
    parsed = extract_json(raw)

    if parsed:
        return parsed

    # fallback
    return extract_loose(raw)
