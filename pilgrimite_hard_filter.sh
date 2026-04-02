#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Applying HARD OUTPUT FILTER..."

# Replace clean_output with strict version
sed -i '/clean_output()/,/^}/c\
clean_output() {\
  sed -E '\''\
    /---/,$d; \
    /Note:|AI|prompt|fictional|not a real person/d; \
    /To make this|Am I understanding|Yes!/d; \
    s/\[.*\]//g; \
    /^LinkedIn Message:/d; \
    /^Email Pitch:/d; \
    /^Service Offer:/d; \
    /^[[:space:]]*$/d; \
  '\'' \
  | awk '\''!seen[$0]++'\'' \
  | head -n 20\
}' "$FILE"

echo "[PATCH] HARD FILTER ACTIVE"
