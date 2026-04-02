#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "QWEN BOOT SEQUENCE"
echo "===================================="

MODEL="$HOME/amethyst/brains/qwen/qwen2.5-3b-instruct-q4_k_m.gguf"
LOG="$HOME/repos/odin_os/logs/qwen.log"
PID="$HOME/repos/odin_os/runtime/qwen.pid"

mkdir -p "$HOME/repos/odin_os/logs"
mkdir -p "$HOME/repos/odin_os/runtime"

# Check model
if [ ! -f "$MODEL" ]; then
  echo "[ERROR] Model not found:"
  echo "$MODEL"
  exit 1
fi

echo "[OK] model found"

# Kill existing
if [ -f "$PID" ]; then
  OLD_PID=$(cat "$PID" || true)
  if kill -0 "$OLD_PID" 2>/dev/null; then
    echo "[STOP] existing qwen (PID $OLD_PID)"
    kill "$OLD_PID" || true
    sleep 1
  fi
fi

# Locate llama-server
LLAMA=""
for p in \
  "$HOME/repos/odin_os/llama.cpp/llama-server" \
  "$HOME/llama.cpp/llama-server" \
  "$(command -v llama-server 2>/dev/null || true)"
do
  if [ -x "$p" ]; then
    LLAMA="$p"
    break
  fi
done

if [ -z "$LLAMA" ]; then
  echo "[ERROR] llama-server not found"
  exit 1
fi

echo "[OK] llama-server found: $LLAMA"

# Start server
echo "[START] qwen on port 8081"

nohup "$LLAMA" \
  -m "$MODEL" \
  --port 8081 \
  > "$LOG" 2>&1 &

NEW_PID=$!
echo $NEW_PID > "$PID"

sleep 2

# Verify
if ss -tuln | grep -q ":8081"; then
  echo "[OK] Qwen running on 8081 (PID $NEW_PID)"
else
  echo "[WARN] Port 8081 not confirmed"
fi

echo "===================================="
