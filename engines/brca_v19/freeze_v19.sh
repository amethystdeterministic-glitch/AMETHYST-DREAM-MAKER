#!/data/data/com.termux/files/usr/bin/bash

STAMP=$(date -u +"%Y%m%dT%H%M%SZ")
DEST="$HOME/repos/odin_os/artifacts/brca_v19_runs/FREEZE_$STAMP"

mkdir -p "$DEST"
cp -r ~/repos/odin_os/specs "$DEST/"

echo "FREEZE COMPLETE: $DEST"
