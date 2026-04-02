#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "DANCE SHUTDOWN"
echo "===================================="

STATE_FILE="$HOME/repos/odin_os/runtime/dance_state.json"

if [ -f "$STATE_FILE" ]; then
  rm -f "$STATE_FILE"
  echo "[OK] DANCE stopped"
else
  echo "[SKIP] no DANCE state"
fi

echo "===================================="
