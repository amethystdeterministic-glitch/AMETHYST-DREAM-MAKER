#!/data/data/com.termux/files/usr/bin/bash

LOCKFILE=/tmp/brca_v19.lock

if [ -f "$LOCKFILE" ]; then
    echo "[LOCKED] Another run in progress"
    exit 1
fi

touch "$LOCKFILE"

trap "rm -f $LOCKFILE" EXIT

"$@"
