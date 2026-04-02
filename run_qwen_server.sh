#!/usr/bin/env bash
set -euo pipefail

MODEL="/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-1.5b-instruct-q4_k_m.gguf"
BIN="/data/data/com.termux/files/home/odin_runtime/llama.cpp/build/bin/llama-server"

echo "[QWEN] starting server on :8081..."

$BIN \
  -m "$MODEL" \
  --host 127.0.0.1 \
  --port 8081 \
  --ctx-size 2048 \
  --threads 4 \
  --no-webui \
  > ~/.qwen_server.log 2>&1 &

echo $! > ~/.qwen_server.pid

echo "[QWEN] PID: $(cat ~/.qwen_server.pid)"
