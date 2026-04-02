#!/data/data/com.termux/files/usr/bin/bash

LATEST=$(ls -td ~/repos/odin_os/artifacts/brca_v19_runs/* 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
    echo "[NO RUNS FOUND]"
    exit 1
fi

for f in "$LATEST"/DATASETS/*/*.tsv; do
    [ -e "$f" ] || continue

    d=$(dirname "$f")

    python3 ~/repos/odin_os/engines/brca_v19/benchmark/runner.py \
        "$f" "$d/benchmark.json"
done

echo "[BENCHMARK COMPLETE]"
