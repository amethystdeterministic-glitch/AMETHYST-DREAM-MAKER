#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "ODIN PUBLISH — FREEZE → GIT"
echo "===================================="

# Resolve repo root
cd ~/repos/odin_os || exit 1

# Find latest freeze
LATEST_FREEZE=$(ls -td artifacts/freeze/ODIN_FREEZE_* 2>/dev/null | head -n 1)

if [ -z "$LATEST_FREEZE" ]; then
  echo "[ERROR] No freeze found."
  exit 1
fi

echo "[INFO] Latest freeze: $LATEST_FREEZE"

echo "[GIT] staging freeze..."
git add "$LATEST_FREEZE"

echo "[GIT] committing..."
git commit -m "ODIN FREEZE $(basename "$LATEST_FREEZE")"

echo "[GIT] pushing..."
git push origin apk_rebuild_clean_v1

echo "===================================="
echo "PUBLISH COMPLETE"
echo "===================================="
