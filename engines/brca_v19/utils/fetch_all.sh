#!/data/data/com.termux/files/usr/bin/bash

FETCH=~/data/brca_fetch
RAW=~/data/brca_raw

mkdir -p "$FETCH"
mkdir -p "$RAW"

# GEO
bash ~/repos/odin_os/engines/brca_v19/utils/fetch_geo.sh

# convert GEO files
for f in "$FETCH"/*.txt; do
    [ -e "$f" ] || continue

    name=$(basename "$f" .txt)

    python3 ~/repos/odin_os/engines/brca_v19/utils/geo_to_tsv.py \
        "$f" "$RAW/${name}.tsv"
done

echo "[ALL FETCH COMPLETE]"
