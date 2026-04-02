#!/usr/bin/env bash
set -e

PID_FILE=~/.amethyst_pids/enforcement.pid

if [ ! -f "$PID_FILE" ]; then
  echo "[VERIFY] FAIL: no PID file"
  exit 1
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null; then
  echo "[VERIFY] PROCESS ALIVE: $PID"
else
  echo "[VERIFY] FAIL: process dead"
  exit 1
fi

echo "[VERIFY] CURL:"
curl -s http://127.0.0.1:7878/health || echo "[VERIFY] curl failed"
