#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "DANCE GOVERNANCE LAYER — START"
echo "===================================="

RUNTIME="$HOME/repos/odin_os/runtime"
mkdir -p "$RUNTIME"

cat > "$RUNTIME/dance_state.json" << 'JSON'
{
  "status": "active",
  "mode": "deterministic",
  "policy": "default",
  "last_check": "boot"
}
JSON

echo "[OK] DANCE state initialised"
echo "===================================="
echo "DANCE ACTIVE"
echo "===================================="
