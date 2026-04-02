#!/data/data/com.termux/files/usr/bin/bash
set -e

cd ~/repos/odin_os/core/dre
cargo build --release

echo
echo "[OK] rebuilt:"
ls -lh target/release/dre
