#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "===================================="
echo "PATCH: QWEN INTO ODIN"
echo "===================================="

ODIN_ON="$HOME/repos/odin_os/odin_on"
ODIN_OFF="$HOME/repos/odin_os/odin_off"

# --- PATCH ODIN_ON ---
if ! grep -q "qwen_start.sh" "$ODIN_ON"; then
  sed -i '/runtime + logs ready/a\
echo "[START] qwen"\
bash ~/repos/odin_os/qwen_start.sh\
' "$ODIN_ON"
  echo "[OK] qwen injected into odin_on"
else
  echo "[SKIP] qwen already in odin_on"
fi

# --- PATCH ODIN_OFF ---
if ! grep -q "qwen_off.sh" "$ODIN_OFF"; then
  sed -i '/STATE: OFF/i\
bash ~/repos/odin_os/qwen_off.sh\
' "$ODIN_OFF"
  echo "[OK] qwen injected into odin_off"
else
  echo "[SKIP] qwen already in odin_off"
fi

echo "===================================="
echo "PATCH COMPLETE"
echo "===================================="
