#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "QWEN START (ANDROID SAFE)"
echo "===================================="

MODEL="/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-1.5b-instruct-q4_k_m.gguf"
PORT=8081
LOG="$HOME/repos/odin_os/logs/qwen.log"
PID="$HOME/repos/odin_os/runtime/qwen.pid"

mkdir -p "$HOME/repos/odin_os/logs"
mkdir -p "$HOME/repos/odin_os/runtime"

# --- CHECK MODEL ---
if [ ! -f "$MODEL" ]; then
  echo "[ERROR] Model not found:"
  echo "$MODEL"
  exit 1
fi

echo "[OK] model found"

# --- KILL EXISTING ---
if [ -f "$PID" ]; then
  OLD_PID=$(cat "$PID" || true)
  kill "$OLD_PID" 2>/dev/null || true
  sleep 1
fi

# --- FIND LLAMA SERVER ---
LLAMA="$(command -v llama-server || true)"

if [ -z "$LLAMA" ]; then
  echo "[ERROR] llama-server not found"
  exit 1
fi

echo "[OK] llama-server: $LLAMA"

# --- START ---
echo "[START] launching Qwen on port $PORT"

nohup "$LLAMA" \
  -m "$MODEL" \
  --host 127.0.0.1 \
  --port $PORT \
  --ctx-size 4096 \
  --n-gpu-layers 0 \
  > "$LOG" 2>&1 &

echo $! > "$PID"

sleep 4

# --- VERIFY VIA CURL (REAL CHECK) ---
if curl -s http://127.0.0.1:$PORT/health | grep -q "ok"; then
  echo "[OK] Qwen responding"
else
  echo "[WARN] Qwen not responding yet"
  echo "[TIP] check logs:"
  echo "tail -f $LOG"
fi

echo "===================================="
echo "QWEN READY"
echo "===================================="
