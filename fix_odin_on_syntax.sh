#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_ON="$HOME/repos/odin_os/odin_on"

echo "===================================="
echo "FIX ODIN_ON SYNTAX"
echo "===================================="

# Backup first (important)
cp "$ODIN_ON" "$ODIN_ON.bak"

# Remove stray 'fi' at end of file if present
# (common after sed block removal)
sed -i '${/^fi$/d;}' "$ODIN_ON"

# Also remove any double 'fi' sequences
sed -i 's/fi[[:space:]]*fi/fi/g' "$ODIN_ON"

echo "[OK] syntax cleaned"

echo "===================================="
echo "DONE"
echo "===================================="
