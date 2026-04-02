#!/data/data/com.termux/files/usr/bin/bash

INPUT=$1

NAME=$(basename "$INPUT" .tsv)

PROC=~/data/brca_processed/${NAME}_clean.tsv
FINAL=~/data/brca_datasets/${NAME}.tsv

echo "[PIPELINE] START $NAME"

# ingest
python3 ~/repos/odin_os/engines/brca_v19/utils/ingest_geo.py "$INPUT" "$PROC"

# normalize
python3 ~/repos/odin_os/engines/brca_v19/utils/normalize.py "$PROC" "$FINAL"

# validate
python3 ~/repos/odin_os/engines/brca_v19/utils/validate_dataset.py "$FINAL"

# run engine
~/repos/odin_os/engines/brca_v19/run_v19.sh

echo "[PIPELINE] COMPLETE $NAME"
