#!/usr/bin/env bash
set -e

BIN_DIR="target/release"

echo "Generating SHA256 checksums..."
find "$BIN_DIR" -maxdepth 1 -type f -executable -exec sha256sum {} \; > release_checksums.txt

echo "Checksums written to release_checksums.txt"
