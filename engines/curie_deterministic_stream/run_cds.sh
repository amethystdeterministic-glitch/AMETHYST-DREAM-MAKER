#!/data/data/com.termux/files/usr/bin/bash
set -e

ENGINE_DIR="/data/data/com.termux/files/home/repos/odin_os/engines/curie_deterministic_stream"

echo "===================================="
echo "CDS — CURIE DETERMINISTIC STREAM"
echo "===================================="

cd "$ENGINE_DIR"

# FORCE standalone build (ignore parent workspace)
cargo run --release --manifest-path "$ENGINE_DIR/Cargo.toml"
