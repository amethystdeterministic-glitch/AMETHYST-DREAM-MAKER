#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_clean.sh"

echo "[FIX] hardening payload handling..."

sed -i 's/payload = x.get("payload","none").replace(" ", "_")/\
payload = x.get("payload")\
if payload is None:\
    payload = "none"\
payload = str(payload).replace(" ", "_")/' "$TARGET"

echo "[FIX] done"
