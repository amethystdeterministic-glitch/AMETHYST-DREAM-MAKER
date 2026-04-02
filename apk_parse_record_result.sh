#!/usr/bin/env bash
set -euo pipefail

DISC="$HOME/repos/odin_os/artifacts/apk_parse_discovery"

ITERATION="${1:-}"
RESULT="${2:-}"
STATUS="${3:-}"

if [ -z "$ITERATION" ] || [ -z "$RESULT" ] || [ -z "$STATUS" ]; then
  echo "USAGE: $0 <ITERATION> <RESULT> <STATUS>"
  echo "EXAMPLE: $0 H1 \"problem parsing package\" rejected"
  echo "EXAMPLE: $0 H2 \"installed successfully\" accepted"
  exit 1
fi

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat >> "$DISC/ITERATION_LOG.jsonl" <<EOFJSON
{"timestamp":"$TS","iteration":"$ITERATION","install":"observed","install_result":"$RESULT","status":"$STATUS"}
EOFJSON

echo "RECORDED $ITERATION -> $STATUS"
