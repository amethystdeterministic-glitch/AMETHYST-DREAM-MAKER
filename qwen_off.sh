#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "===================================="
echo "QWEN SHUTDOWN"
echo "===================================="

PID="$HOME/repos/odin_os/runtime/qwen.pid"

if [ -f "$PID" ]; then
  QPID=$(cat "$PID" || true)

  if kill -0 "$QPID" 2>/dev/null; then
    echo "[STOP] qwen (PID $QPID)"
    kill "$QPID" || true
    sleep 1
    echo "[OK] qwen stopped"
  else
    echo "[WARN] PID file exists but process not running"
  fi

  rm -f "$PID"
else
  echo "[SKIP] qwen no PID file"
fi

echo "===================================="
