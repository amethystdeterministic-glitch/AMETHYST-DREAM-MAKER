import json, os, re

raw = os.environ.get("RAW_DATA","").strip()
data = json.loads(raw)
content = data.get("content","")

matches = re.findall(r'\{[^{}]*\}', content)

ALLOWED = {"deploy", "test", "status"}

seen = set()
seen_filtered = set()

actions = []
filtered = []

for m in matches:
    try:
        obj = json.loads(m)

        action = obj.get("action","").strip().lower()
        payload = obj.get("payload","").strip()

        if payload == "":
            payload = "none"

        payload = payload.replace(" ", "_")

        if action == "..." or payload == "...":
            continue

        key = f"{action}:{payload}".lower()

        if action not in ALLOWED:
            if key not in seen_filtered:
                seen_filtered.add(key)
                filtered.append({
                    "action": action,
                    "payload": payload,
                    "reason": "not_allowed"
                })
            continue

        if key in seen:
            continue

        seen.add(key)

        actions.append({
            "action": action,
            "payload": payload
        })

    except:
        continue

print(json.dumps({
    "actions": actions,
    "filtered": filtered
}))
