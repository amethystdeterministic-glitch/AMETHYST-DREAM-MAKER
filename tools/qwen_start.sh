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
