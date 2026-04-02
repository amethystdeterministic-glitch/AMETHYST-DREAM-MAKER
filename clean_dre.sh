#!/usr/bin/env bash
set -e

echo "[CLEAN] Removing old dre build artifacts..."

rm -rf ~/repos/odin_os/core/dre/target
rm -rf ~/repos/odin_os/target/release/dre

echo "[CLEAN] Done"
