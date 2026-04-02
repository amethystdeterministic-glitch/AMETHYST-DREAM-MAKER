#!/data/data/com.termux/files/usr/bin/bash

WATCH_DIR=~/data/brca_raw
PROCESSED_FLAG=~/data/brca_raw/.processed

mkdir -p "$WATCH_DIR"
touch "$PROCESSED_FLAG"

echo "[WATCHER] Monitoring $WATCH_DIR"

while true; do
    for f in "$WATCH_DIR"/*.tsv; do
        [ -e "$f" ] || continue

        name=$(basename "$f")

        if ! grep -q "$name" "$PROCESSED_FLAG"; then
            echo "[DETECTED] $name"

            echo "$name" >> "$PROCESSED_FLAG"

            bash ~/repos/odin_os/engines/brca_v19/utils/pipeline_trigger.sh "$f"
        fi
    done

    sleep 10
done
