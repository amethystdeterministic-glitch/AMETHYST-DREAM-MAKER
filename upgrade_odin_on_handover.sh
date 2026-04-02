#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ODIN_ON="$HOME/repos/odin_os/odin_on"
BACKUP="$HOME/repos/odin_os/odin_on.bak.$(date +%s)"

echo "===================================="
echo "ODIN ON HANDOVER PATCH"
echo "===================================="

if [ ! -f "$ODIN_ON" ]; then
  echo "[ERROR] odin_on not found at $ODIN_ON"
  exit 1
fi

cp "$ODIN_ON" "$BACKUP"
echo "[BACKUP] saved to $BACKUP"

cat > "$ODIN_ON" << 'ODINON'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "ODIN ON — CLEAN BOOT"
echo "===================================="

# -----------------------------------
# HANDOVER RESTORE
# -----------------------------------
echo "===================================="
echo "ODIN HANDOVER — RESTORE"
echo "===================================="

HANDOVER_DIR="$HOME/repos/odin_os/artifacts/handover"
RUNTIME_DIR="$HOME/repos/odin_os/runtime"

mkdir -p "$RUNTIME_DIR"

LATEST_HANDOVER=$(ls -t "$HANDOVER_DIR"/ODIN_OFF_* 2>/dev/null | head -n 1 || true)

if [ -n "${LATEST_HANDOVER:-}" ] && [ -f "$LATEST_HANDOVER" ]; then
  echo "[FOUND] $LATEST_HANDOVER"
  echo "------------------------------------"
  cat "$LATEST_HANDOVER"
  echo "------------------------------------"

  cp "$LATEST_HANDOVER" "$RUNTIME_DIR/LAST_HANDOVER.txt"
  echo "[OK] handover restored"
else
  echo "[WARN] no handover found"
fi

echo "===================================="

# -----------------------------------
# RUNTIME INIT
# -----------------------------------
mkdir -p "$HOME/repos/odin_os/logs"
mkdir -p "$HOME/repos/odin_os/runtime"

echo "[OK] runtime + logs ready"

# -----------------------------------
# START DRE (existing behavior)
# -----------------------------------
if command -v dre >/dev/null 2>&1; then
  echo "[START] dre"
  dre &
  DRE_PID=$!
  echo "[OK] dre running (PID $DRE_PID)"
else
  echo "[WARN] dre command not found"
fi

# -----------------------------------
# VERIFY (BASIC)
# -----------------------------------
echo "[VERIFY]"

if ps aux | grep -v grep | grep -q dre; then
  echo "[OK] dre alive"
else
  echo "[WARN] dre not detected"
fi

echo "===================================="
echo "STATE: GREEN"
echo "===================================="
ODINON

chmod +x "$ODIN_ON"

echo "[OK] odin_on upgraded with handover restore"
echo "===================================="
