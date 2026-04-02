#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ODIN_ON="$HOME/repos/odin_os/odin_on"
ODIN_OFF="$HOME/repos/odin_os/odin_off"

echo "===================================="
echo "PATCH GOVERNED BOOT"
echo "===================================="

if ! grep -q 'dance_on.sh' "$ODIN_ON"; then
  sed -i '/runtime + logs ready/a\
echo "[START] dance"\
bash ~/repos/odin_os/dance_on.sh\
' "$ODIN_ON"
  echo "[OK] injected DANCE into odin_on"
else
  echo "[SKIP] DANCE already in odin_on"
fi

if grep -q '\[START\] dre' "$ODIN_ON"; then
  sed -i '/\[START\] dre/,+5d' "$ODIN_ON"
  echo "[OK] removed old direct DRE boot block"
fi

if ! grep -q 'qwen_dance_dre.sh' "$ODIN_ON"; then
  sed -i '/bash ~\/repos\/odin_os\/qwen_start.sh/a\
echo "[START] governed execution path"\
bash ~/repos/odin_os/qwen_dance_dre.sh\
' "$ODIN_ON"
  echo "[OK] injected governed execution path"
else
  echo "[SKIP] governed execution path already present"
fi

if ! grep -q 'dance_off.sh' "$ODIN_OFF"; then
  sed -i '/STATE: OFF/i\
bash ~/repos/odin_os/dance_off.sh\
' "$ODIN_OFF"
  echo "[OK] injected DANCE shutdown into odin_off"
else
  echo "[SKIP] DANCE shutdown already in odin_off"
fi

echo "===================================="
echo "PATCH COMPLETE"
echo "===================================="
