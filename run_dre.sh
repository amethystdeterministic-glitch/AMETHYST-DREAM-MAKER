#!/usr/bin/env bash
set -e

LOG=~/.amethyst_logs/enforcement.log
PID=~/.amethyst_pids/enforcement.pid

echo "[RUN] Starting D.R.E..."

~/repos/odin_os/target/release/dre > "$LOG" 2>&1 &

echo $! > "$PID"

sleep 1

echo "[RUN] PID: $(cat $PID)"
echo "[RUN] LOG:"
tail -n 5 "$LOG"
