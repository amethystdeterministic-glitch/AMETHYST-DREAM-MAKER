#!/data/data/com.termux/files/usr/bin/bash
set -e

TARGET_DIR=~/repos/odin_os/target/release
mkdir -p "$TARGET_DIR"

BIN=$(find ~/repos/odin_os -type f -name "dre" -executable 2>/dev/null | head -n 1)

if [ -z "$BIN" ]; then
  echo "[ERROR] no binary found to install"
  exit 1
fi

echo "[INSTALL] using: $BIN"

cp "$BIN" "$TARGET_DIR/dre"
chmod +x "$TARGET_DIR/dre"

echo "[OK] installed to $TARGET_DIR/dre"
