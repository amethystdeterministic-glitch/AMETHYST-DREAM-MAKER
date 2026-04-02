#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
ART="$ROOT/artifacts/trading"
LOG="$ART/dcee_runner.log"

mkdir -p "$ART"

echo "====================================" | tee -a "$LOG"
echo "DCEE ENGINE START $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$LOG"
echo "====================================" | tee -a "$LOG"

python3 "$HOME/repos/amethyst_brca_release/dcee_scanner_v1_3_1.py" 2>&1 | tee -a "$LOG"
