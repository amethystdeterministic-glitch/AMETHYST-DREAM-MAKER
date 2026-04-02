#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "V19 FULL AUTO PIPELINE"
echo "===================================="

# fetch
bash ~/repos/odin_os/engines/brca_v19/utils/fetch_all.sh

# ingest
bash ~/repos/odin_os/engines/brca_v19/utils/batch_ingest.sh

# run engine
~/repos/odin_os/engines/brca_v19/run_v19.sh

echo "===================================="
echo "FULL AUTO COMPLETE"
echo "===================================="
