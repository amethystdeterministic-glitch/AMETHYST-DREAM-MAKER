#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ODIN_ON="$HOME/repos/odin_os/odin_on"
DRE_PATH="$HOME/repos/odin_os/target/release/dre"

echo "===================================="
echo "PATCH ODIN_ON — DRE ABSOLUTE PATH"
echo "===================================="

if [ ! -f "$DRE_PATH" ]; then
  echo "[ERROR] dre binary not found at $DRE_PATH"
  exit 1
fi

# Replace any existing dre call
sed -i "s|dre &|$DRE_PATH \&|g" "$ODIN_ON"
sed -i "s|dre$|$DRE_PATH|g" "$ODIN_ON"

echo "[OK] odin_on now uses absolute dre path"
echo "===================================="
