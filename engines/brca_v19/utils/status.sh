#!/data/data/com.termux/files/usr/bin/bash

LATEST=$(ls -td ~/repos/odin_os/artifacts/brca_v19_runs/* 2>/dev/null | head -1)

echo "===================================="
echo "LATEST RUN:"
echo "$LATEST"
echo "===================================="

if [ -f "$LATEST/META/meta_summary.json" ]; then
    cat "$LATEST/META/meta_summary.json"
else
    echo "No summary yet"
fi

echo "===================================="
