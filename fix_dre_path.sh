#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_ON="$HOME/repos/odin_os/odin_on"

# Replace dre call with full path
sed -i 's|dre &|~/repos/odin_os/target/release/dre \&|' "$ODIN_ON"

echo "[OK] dre path fixed"
