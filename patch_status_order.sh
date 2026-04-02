#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_ON="$HOME/repos/odin_os/odin_on"

echo "===================================="
echo "PATCH: MOVE STATUS TO POST-BOOT"
echo "===================================="

# Remove existing status block
sed -i '/\[INFO\] status/,+5d' "$ODIN_ON"

# Append status at end (before STATE: GREEN)
sed -i '/STATE: GREEN/i\
echo "[INFO] status (post-boot)"\
odin_status\
' "$ODIN_ON"

echo "[OK] status moved to post-boot"

echo "===================================="
