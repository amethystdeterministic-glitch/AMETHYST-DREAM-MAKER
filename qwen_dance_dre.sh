#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "QWEN → DANCE → DRE"
echo "===================================="

RUNTIME="$HOME/repos/odin_os/runtime"
DANCE_STATE="$RUNTIME/dance_state.json"
QWEN_HEALTH="http://127.0.0.1:8081/health"
DRE_BIN="$HOME/repos/odin_os/target/release/dre"
DRE_PID_FILE="$RUNTIME/dre.pid"

mkdir -p "$RUNTIME"

if [ ! -f "$DANCE_STATE" ]; then
  echo "[ERROR] DANCE not active"
  exit 1
fi
echo "[OK] DANCE active"

if curl -s "$QWEN_HEALTH" | grep -q "ok"; then
  echo "[OK] Qwen healthy"
else
  echo "[ERROR] Qwen not healthy"
  exit 1
fi

if [ ! -x "$DRE_BIN" ]; then
  echo "[ERROR] DRE binary not found:"
  echo "$DRE_BIN"
  exit 1
fi

if [ -f "$DRE_PID_FILE" ]; then
  OLD_PID="$(cat "$DRE_PID_FILE" 2>/dev/null || true)"
  if [ -n "${OLD_PID:-}" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "[OK] DRE already running (PID $OLD_PID)"
    echo "===================================="
    exit 0
  fi
fi

echo "[START] DRE via governed path"
nohup "$DRE_BIN" > "$HOME/repos/odin_os/logs/dre.log" 2>&1 &
NEW_PID=$!
echo "$NEW_PID" > "$DRE_PID_FILE"

sleep 2

if kill -0 "$NEW_PID" 2>/dev/null; then
  echo "[OK] DRE running (PID $NEW_PID)"
else
  echo "[ERROR] DRE failed to stay up"
  exit 1
fi

echo "===================================="
echo "STACK ACTIVE"
echo "===================================="
