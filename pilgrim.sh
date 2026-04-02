#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

QWEN_URL="http://127.0.0.1:8081/completion"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] python3 not found"
  exit 1
fi

echo "===================================="
echo "PILGRIM AI — INTERACTIVE"
echo "===================================="
echo "Type 'exit' to quit"
echo

while true; do
  printf "You: "
  IFS= read -r input || break

  if [ "$input" = "exit" ] || [ "$input" = "quit" ]; then
    echo "[OK] Pilgrim closed"
    break
  fi

  payload="$(python3 - "$input" <<'PY'
import json, sys
prompt = sys.argv[1]
data = {
    "prompt": f"User: {prompt}\nAssistant:",
    "n_predict": 220,
    "temperature": 0.2,
    "stop": ["User:"]
}
print(json.dumps(data))
PY
)"

  raw="$(curl -sS --max-time 120 "$QWEN_URL" \
    -H "Content-Type: application/json" \
    -d "$payload" || true)"

  if [ -z "$raw" ]; then
    echo "Pilgrim: [no response]"
    continue
  fi

  text="$(python3 - "$raw" <<'PY'
import json, sys
raw = sys.argv[1]
try:
    obj = json.loads(raw)
    if isinstance(obj, dict):
        if "content" in obj:
            print(obj["content"].strip())
        elif "choices" in obj and obj["choices"]:
            choice = obj["choices"][0]
            if isinstance(choice, dict):
                if "text" in choice:
                    print(str(choice["text"]).strip())
                elif "message" in choice and isinstance(choice["message"], dict):
                    print(str(choice["message"].get("content","")).strip())
                else:
                    print(raw)
            else:
                print(raw)
        else:
            print(raw)
    else:
        print(raw)
except Exception:
    print(raw)
PY
)"
  echo "Pilgrim: $text"
  echo
done
