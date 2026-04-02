#!/data/data/com.termux/files/usr/bin/bash

LOG="/data/data/com.termux/files/home/repos/odin_os/artifacts/pi_runner.log"

echo "[PI_RUNNER] starting..." >> "$LOG"

(
  while true; do
    echo "[PI_RUNNER] heartbeat $(date)" >> "$LOG"
    sleep 10
  done
) &

disown
