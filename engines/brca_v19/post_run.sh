#!/data/data/com.termux/files/usr/bin/bash

ROOT=$1

python3 reporting/generate_report.py "$ROOT"

bash ~/repos/odin_os/engines/brca_v19/viz/generate_all.sh

bash ~/repos/odin_os/engines/brca_v19/benchmark/run_all.sh

bash ~/repos/odin_os/engines/brca_v19/package/build_package.sh "$ROOT"

echo "[POST] REPORT + FIGURES + BENCHMARK + PACKAGE GENERATED"
