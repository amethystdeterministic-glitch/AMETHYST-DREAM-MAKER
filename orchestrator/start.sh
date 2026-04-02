#!/data/data/com.termux/files/usr/bin/bash

LOG="/data/data/com.termux/files/home/repos/odin_os/artifacts/orchestrator.log"
mkdir -p "$(dirname "$LOG")"

(
  echo "[ORCHESTRATOR] starting $(date)"
  while true; do
    echo "[ORCHESTRATOR] heartbeat $(date)"
    sleep 15
  done
) >> "$LOG" 2>&1 &

disown
