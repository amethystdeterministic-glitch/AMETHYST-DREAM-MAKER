#!/data/data/com.termux/files/usr/bin/bash

HANDOVER_DIR=~/repos/odin_os/artifacts/handover

echo "===================================="
echo "ODIN ON — SYSTEM BOOT"
echo "===================================="

LATEST=$(ls -t $HANDOVER_DIR/ODIN_OFF_* 2>/dev/null | head -n 1)

if [ -z "$LATEST" ]; then
  echo "[WARN] No ODIN_OFF snapshot found"
else
  echo "[OK] Loading last state:"
  echo "$LATEST"
  echo "------------------------------------"
  head -n 40 "$LATEST"
  echo "------------------------------------"
fi

echo ""
echo "[BOOT] Rehydrating runtime..."

# Restart core services (adjust if needed)
pkill -f llama-server 2>/dev/null
pkill -f enforcement 2>/dev/null
pkill -f captain 2>/dev/null

sleep 1

# Example restarts (adapt to your actual scripts)
~/repos/odin_os/enforcement &
~/repos/odin_os/captain &
~/repos/odin_os/pilgrim_llama_start.sh &

sleep 2

echo ""
echo "[STATE] Checking processes..."
ps aux | grep -E "llama|captain|enforcement" | grep -v grep

echo ""
echo "[DISCOVERY CONTEXT]"
LATEST_DISC=$(ls -t ~/repos/odin_os/artifacts/discoveries 2>/dev/null | head -n 1)

if [ -n "$LATEST_DISC" ]; then
  echo "Latest Discovery: $LATEST_DISC"
  echo "Path: ~/repos/odin_os/artifacts/discoveries/$LATEST_DISC"
else
  echo "No discoveries found"
fi

echo ""
echo "===================================="
echo "STATE: REHYDRATED"
echo "MODE: CONTINUATION"
echo "DISCOVERY PROTOCOL: ACTIVE"
echo "===================================="
