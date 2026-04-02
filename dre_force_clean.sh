#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "===================================="
echo "DRE FORCE CLEAN — PRE-BIND SANITY"
echo "===================================="

echo "[STEP] killing any rogue dre processes..."
pkill -f "/repos/odin_os/.*/dre" 2>/dev/null || true
sleep 1

echo "[STEP] verifying port 7878..."
if command -v lsof >/dev/null 2>&1; then
  lsof -i :7878 || echo "[OK] port free"
else
  echo "[INFO] lsof unavailable"
fi

echo "[STEP] clearing stale PID..."
rm -f ~/repos/odin_os/runtime/pids/dre.pid

echo "[OK] environment clean"
