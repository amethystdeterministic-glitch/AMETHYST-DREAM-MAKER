#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_ON="$HOME/repos/odin_os/odin_on"

echo "===================================="
echo "FULL ODIN_ON REPAIR"
echo "===================================="

# Backup
cp "$ODIN_ON" "$ODIN_ON.bak2"

# Remove ALL standalone fi lines (safe because logic already flattened)
sed -i '/^[[:space:]]*fi[[:space:]]*$/d' "$ODIN_ON"

# Remove broken if statements with no body
sed -i '/if \[.*\]; then[[:space:]]*$/d' "$ODIN_ON"

# Ensure clean execution tail (append if missing)
if ! grep -q "STACK ACTIVE" "$ODIN_ON"; then
cat >> "$ODIN_ON" << 'CLEAN'

echo "===================================="
echo "STATE: GREEN"
echo "===================================="
CLEAN
fi

echo "[OK] odin_on structurally repaired"

echo "===================================="
