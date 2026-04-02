#!/data/data/com.termux/files/usr/bin/bash

LATEST=$(ls -td ~/repos/odin_os/artifacts/brca_v19_runs/* 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
    echo "[HEALTH] No runs found"
    exit 1
fi

if [ -f "$LATEST/META/meta_summary.json" ]; then
    verdict=$(cat "$LATEST/META/meta_summary.json" | grep program_verdict)

    echo "[HEALTH] OK → $verdict"
else
    echo "[HEALTH] WARNING → No summary"
fi
