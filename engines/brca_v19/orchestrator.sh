#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "AMETHYST BRCA V19 ORCHESTRATOR"
echo "===================================="

LOG=~/repos/odin_os/logs/brca_v19/orchestrator.log
mkdir -p $(dirname "$LOG")

while true; do

    echo "[CYCLE START] $(date -u)" | tee -a "$LOG"

    # Step 1: Fetch new data
    bash ~/repos/odin_os/engines/brca_v19/utils/fetch_all.sh >> "$LOG" 2>&1

    # Step 2: Ingest + normalize
    bash ~/repos/odin_os/engines/brca_v19/utils/batch_ingest.sh >> "$LOG" 2>&1

    # Step 3: Execute engine
    ~/repos/odin_os/engines/brca_v19/run_v19.sh >> "$LOG" 2>&1

    # Step 4: Health check
    bash ~/repos/odin_os/engines/brca_v19/utils/health_check.sh >> "$LOG" 2>&1

    echo "[CYCLE COMPLETE] $(date -u)" | tee -a "$LOG"

    sleep 3600  # run every hour

done
