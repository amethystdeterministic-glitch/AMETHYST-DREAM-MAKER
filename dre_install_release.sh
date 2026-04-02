#!/data/data/com.termux/files/usr/bin/bash
set -e

SRC=~/repos/odin_os/core/dre/target/release/dre
DST=~/repos/odin_os/target/release/dre

mkdir -p ~/repos/odin_os/target/release
cp "$SRC" "$DST"
chmod +x "$DST"

echo "[OK] installed to $DST"
