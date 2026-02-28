#!/usr/bin/env bash
set -e

echo "Building ODIN Force Engine (release mode)..."
cargo build --release -j 1

echo "Release build complete."
