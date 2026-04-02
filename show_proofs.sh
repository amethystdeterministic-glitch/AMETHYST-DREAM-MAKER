#!/usr/bin/env bash
set -e

LOG=~/.amethyst_logs/enforcement.jsonl

if [ ! -f "$LOG" ]; then
  echo "[PROOF] no enforcement log found"
  exit 1
fi

tail -n 20 "$LOG"
