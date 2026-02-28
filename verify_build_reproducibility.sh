#!/usr/bin/env bash
set -e

hash_release() {
    find target/release -maxdepth 1 -type f -executable ! -name "*.d" -exec sha256sum {} \; | sort
}

rm -rf target
cargo build --release -j 1
hash_release > build_hash_1.txt

rm -rf target
cargo build --release -j 1
hash_release > build_hash_2.txt

if diff build_hash_1.txt build_hash_2.txt > /dev/null; then
    echo "Reproducible build confirmed"
else
    echo "Builds differ — reproducibility failed"
    exit 1
fi
