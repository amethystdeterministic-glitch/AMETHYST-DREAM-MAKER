#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_ON="$HOME/repos/odin_os/odin_on"

echo "===================================="
echo "PATCH: ENGINES + STATUS INTO ODIN_ON"
echo "===================================="

# Only inject if not already present
if ! grep -q "odin_engines" "$ODIN_ON"; then
  sed -i '/runtime + logs ready/a\
echo "[INFO] engines"\
odin_engines\
echo "[INFO] status"\
odin_status\
' "$ODIN_ON"

  echo "[OK] injected engines + status"
else
  echo "[SKIP] already present"
fi

echo "===================================="
