#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v2.sh"

echo "[PATCH] Adding timeout + debug to Qwen calls..."

sed -i '/call_qwen()/,/^}/c\
call_qwen() {\
  local prompt="$1"\
  local json\
  json=$(jq -n --arg p "$prompt" '\''{prompt: $p, n_predict: 500, temperature: 0.2}'\'')\
\
  echo "[QWEN] sending request..."\
\
  curl --max-time 20 -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$json" || echo "{\"error\":\"timeout_or_connection_failure\"}"\
}' "$FILE"

echo "[PATCH] COMPLETE"
