#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
RUNTIME="$HOME/repos/odin_os/runtime"

if [ -f "$RUNTIME/qwen.pid" ]; then
  PID="$(cat "$RUNTIME/qwen.pid" 2>/dev/null || true)"
  if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    sleep 1
    kill -9 "$PID" 2>/dev/null || true
    echo "[OK] qwen stopped"
  else
    echo "[SKIP] qwen pid file stale"
  fi
  rm -f "$RUNTIME/qwen.pid"
else
  echo "[SKIP] qwen no PID file"
fi
