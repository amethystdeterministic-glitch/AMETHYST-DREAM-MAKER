#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
RUNTIME="$HOME/repos/odin_os/runtime"

if [ -f "$RUNTIME/captain.pid" ]; then
  PID="$(cat "$RUNTIME/captain.pid" 2>/dev/null || true)"
  if [ -n "${PID:-}" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    sleep 1
    kill -9 "$PID" 2>/dev/null || true
    echo "[OK] captain stopped"
  else
    echo "[SKIP] captain pid file stale"
  fi
  rm -f "$RUNTIME/captain.pid"
else
  echo "[SKIP] captain no PID file"
fi
