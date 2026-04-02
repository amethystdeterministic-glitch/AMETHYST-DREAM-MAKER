#!/usr/bin/env bash
set -e

ACTION="$1"
PAYLOAD="$2"

if [ -z "$ACTION" ] || [ -z "$PAYLOAD" ]; then
  echo "Usage: pilgrim_enforce.sh <action> <payload>"
  exit 1
fi

curl -s -X POST http://127.0.0.1:7878/enforce \
  -H "Content-Type: application/json" \
  -d "{\"action\":\"$ACTION\",\"payload\":\"$PAYLOAD\"}"
