#!/usr/bin/env bash
set -e

PID_FILE=~/.amethyst_pids/enforcement.pid

if [ ! -f "$PID_FILE" ]; then
  echo "[STOP] No PID file"
  exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null; then
  echo "[STOP] Killing D.R.E. ($PID)"
  kill "$PID"
else
  echo "[STOP] Process already dead"
fi

rm -f "$PID_FILE"

echo "[STOP] Done"
