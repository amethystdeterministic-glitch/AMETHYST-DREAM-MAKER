#!/data/data/com.termux/files/usr/bin/bash

ROOT=$1

OUT="$ROOT/LEDGER/integrity_manifest.sha256"

find "$ROOT" -type f | while read f; do
    sha256sum "$f"
done > "$OUT"

echo "[MANIFEST] BUILT $OUT"
