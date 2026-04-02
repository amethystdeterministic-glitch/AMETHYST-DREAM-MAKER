#!/data/data/com.termux/files/usr/bin/bash

LOG=~/repos/odin_os/logs/brca_v19/orchestrator.log

if grep -q "FAIL" "$LOG"; then
    echo "[ALERT] FAILURE DETECTED"

    echo "---- LAST 20 LINES ----"
    tail -20 "$LOG"
fi
