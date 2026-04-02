#!/usr/bin/env bash
set -e

cd ~/repos/odin_os

echo "[BUILD] Building D.R.E..."

cargo build -p dre --release

echo "[BUILD] Complete"
