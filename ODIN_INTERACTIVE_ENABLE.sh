#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/repos/odin_os"
TOOLS="$BASE/tools"
LOGS="$BASE/logs"
RUNTIME="$BASE/runtime"
MODEL="$HOME/amethyst/brains/qwen/qwen2.5-3b-instruct-q4_k_m.gguf"

mkdir -p "$TOOLS" "$LOGS" "$RUNTIME"

cat > "$BASE/pilgrim.sh" <<'PILGRIM'
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
PILGRIM
chmod +x "$BASE/pilgrim.sh"

cat > "$TOOLS/qwen_start.sh" <<'QWENSTART'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/repos/odin_os"
LOGS="$BASE/logs"
RUNTIME="$BASE/runtime"
MODEL="$HOME/amethyst/brains/qwen/qwen2.5-3b-instruct-q4_k_m.gguf"

mkdir -p "$LOGS" "$RUNTIME"

if ss -tuln 2>/dev/null | grep -q ':8081 '; then
  echo "[OK] qwen already listening on 8081"
  exit 0
fi

LLAMA_SERVER=""
for p in \
  "$BASE/llama.cpp/llama-server" \
  "$HOME/llama.cpp/llama-server" \
  "$HOME/amethyst/llama.cpp/llama-server" \
  "$(command -v llama-server 2>/dev/null || true)"
do
  if [ -n "$p" ] && [ -x "$p" ]; then
    LLAMA_SERVER="$p"
    break
  fi
done

if [ -z "$LLAMA_SERVER" ]; then
  echo "[WARN] qwen not started — llama-server not found"
  exit 0
fi

if [ ! -f "$MODEL" ]; then
  echo "[WARN] qwen not started — model missing at $MODEL"
  exit 0
fi

nohup "$LLAMA_SERVER" \
  -m "$MODEL" \
  --port 8081 \
  > "$LOGS/qwen.log" 2>&1 &

echo $! > "$RUNTIME/qwen.pid"

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if ss -tuln 2>/dev/null | grep -q ':8081 '; then
    echo "[OK] qwen running on 8081"
    exit 0
  fi
  sleep 1
done

echo "[WARN] qwen start attempted but 8081 not confirmed"
exit 0
QWENSTART
chmod +x "$TOOLS/qwen_start.sh"

cat > "$TOOLS/qwen_stop.sh" <<'QWENSTOP'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
RUNTIME="$HOME/repos/odin_os/runtime"

if [ -f "$RUNTIME/qwen.pid" ]; then
  PID="$(cat "$RUNTIME/qwen.pid" 2>/dev/null || true)"
  if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    sleep 1
    kill -9 "$PID" 2>/dev/null || true
    echo "[OK] qwen stopped"
  else
    echo "[SKIP] qwen pid file stale"
  fi
  rm -f "$RUNTIME/qwen.pid"
else
  echo "[SKIP] qwen no PID file"
fi
QWENSTOP
chmod +x "$TOOLS/qwen_stop.sh"

cat > "$TOOLS/captain_start.sh" <<'CAPSTART'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/repos/odin_os"
LOGS="$BASE/logs"
RUNTIME="$BASE/runtime"

mkdir -p "$LOGS" "$RUNTIME"

if ss -tuln 2>/dev/null | grep -q ':7171 '; then
  echo "[OK] captain already listening on 7171"
  exit 0
fi

CAPTAIN_CMD=""
for p in \
  "$BASE/captain/start.sh" \
  "$BASE/captain/start_captain.sh" \
  "$BASE/captain.sh" \
  "$BASE/bin/captain" \
  "$BASE/captain/captain"
do
  if [ -f "$p" ] && [ -x "$p" ]; then
    CAPTAIN_CMD="$p"
    break
  fi
done

if [ -z "$CAPTAIN_CMD" ]; then
  echo "[SKIP] captain entrypoint not found"
  exit 0
fi

if [[ "$CAPTAIN_CMD" == *.sh ]]; then
  nohup bash "$CAPTAIN_CMD" > "$LOGS/captain.log" 2>&1 &
else
  nohup "$CAPTAIN_CMD" > "$LOGS/captain.log" 2>&1 &
fi

echo $! > "$RUNTIME/captain.pid"

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if ss -tuln 2>/dev/null | grep -q ':7171 '; then
    echo "[OK] captain running on 7171"
    exit 0
  fi
  sleep 1
done

echo "[WARN] captain start attempted but 7171 not confirmed"
exit 0
CAPSTART
chmod +x "$TOOLS/captain_start.sh"

cat > "$TOOLS/captain_stop.sh" <<'CAPSTOP'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
RUNTIME="$HOME/repos/odin_os/runtime"

if [ -f "$RUNTIME/captain.pid" ]; then
  PID="$(cat "$RUNTIME/captain.pid" 2>/dev/null || true)"
  if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    sleep 1
    kill -9 "$PID" 2>/dev/null || true
    echo "[OK] captain stopped"
  else
    echo "[SKIP] captain pid file stale"
  fi
  rm -f "$RUNTIME/captain.pid"
else
  echo "[SKIP] captain no PID file"
fi
CAPSTOP
chmod +x "$TOOLS/captain_stop.sh"

cat > "$BASE/odin_interactive_on" <<'ON'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "ODIN INTERACTIVE ON"
echo "===================================="

if command -v odin_on >/dev/null 2>&1; then
  odin_on
else
  echo "[WARN] odin_on command not found"
fi

"$HOME/repos/odin_os/tools/qwen_start.sh"
"$HOME/repos/odin_os/tools/captain_start.sh"

echo "[VERIFY]"
if ss -tuln 2>/dev/null | grep -q ':8081 '; then
  echo "[OK] qwen 8081"
else
  echo "[WARN] qwen not confirmed"
fi

if ss -tuln 2>/dev/null | grep -q ':7171 '; then
  echo "[OK] captain 7171"
else
  echo "[WARN] captain not confirmed"
fi

if ps -ef 2>/dev/null | grep -v grep | grep -q "dre"; then
  echo "[OK] dre process present"
else
  echo "[WARN] dre not confirmed"
fi

echo "===================================="
echo "LAUNCHING PILGRIM AI"
echo "===================================="
exec "$HOME/repos/odin_os/pilgrim.sh"
ON
chmod +x "$BASE/odin_interactive_on"

cat > "$BASE/odin_interactive_off" <<'OFF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "ODIN INTERACTIVE OFF"
echo "===================================="

"$HOME/repos/odin_os/tools/captain_stop.sh"
"$HOME/repos/odin_os/tools/qwen_stop.sh"

if command -v odin_off >/dev/null 2>&1; then
  odin_off
else
  echo "[WARN] odin_off command not found"
fi
OFF
chmod +x "$BASE/odin_interactive_off"

echo
echo "[OK] created:"
echo "  $BASE/pilgrim.sh"
echo "  $BASE/odin_interactive_on"
echo "  $BASE/odin_interactive_off"
echo
echo "Run:"
echo "  ~/repos/odin_os/odin_interactive_on"
