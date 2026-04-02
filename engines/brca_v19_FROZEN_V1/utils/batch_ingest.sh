#!/data/data/com.termux/files/usr/bin/bash

RAW=~/data/brca_raw
PROC=~/data/brca_processed
FINAL=~/data/brca_datasets

mkdir -p "$PROC"
mkdir -p "$FINAL"

for f in "$RAW"/*.tsv; do
    name=$(basename "$f" .tsv)

    echo "[INGEST] $name"

    python3 ~/repos/odin_os/engines/brca_v19/utils/ingest_geo.py \
        "$f" "$PROC/${name}_clean.tsv"

    python3 ~/repos/odin_os/engines/brca_v19/utils/normalize.py \
        "$PROC/${name}_clean.tsv" "$FINAL/${name}.tsv"

    # register dataset
    bash ~/repos/odin_os/engines/brca_v19/utils/auto_register.sh "$FINAL/${name}.tsv"

done

echo "[BATCH INGEST COMPLETE + REGISTERED]"
