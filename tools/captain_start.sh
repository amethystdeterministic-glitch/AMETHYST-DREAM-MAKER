#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="$HOME/repos/odin_os"
LOGS="$BASE/logs"
RUNTIME="$BASE/runtime"

mkdir -p "$LOGS" "$RUNTIME"

if ss -tuln 2>/dev/null | grep -q ':7171 '; then
  echo "[OK] captain already listening on 7171"
  exit 0
fi

CAPTAIN_CMD=""
for p in \
  "$BASE/captain/start.sh" \
  "$BASE/captain/start_captain.sh" \
  "$BASE/captain.sh" \
  "$BASE/bin/captain" \
  "$BASE/captain/captain"
do
  if [ -f "$p" ] && [ -x "$p" ]; then
    CAPTAIN_CMD="$p"
    break
  fi
done

if [ -z "$CAPTAIN_CMD" ]; then
  echo "[SKIP] captain entrypoint not found"
  exit 0
fi

if [[ "$CAPTAIN_CMD" == *.sh ]]; then
  nohup bash "$CAPTAIN_CMD" > "$LOGS/captain.log" 2>&1 &
else
  nohup "$CAPTAIN_CMD" > "$LOGS/captain.log" 2>&1 &
fi

echo $! > "$RUNTIME/captain.pid"

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if ss -tuln 2>/dev/null | grep -q ':7171 '; then
    echo "[OK] captain running on 7171"
    exit 0
  fi
  sleep 1
done

echo "[WARN] captain start attempted but 7171 not confirmed"
exit 0
