#!/data/data/com.termux/files/usr/bin/bash

NAME=$1

BASE=~/repos/odin_os
PID_FILE=$BASE/runtime/pids/${NAME}.pid

SELF_PID=$$
PARENT_PID=$PPID

if [ ! -f "$PID_FILE" ]; then
  echo "[SKIP] $NAME no PID file"
  exit 0
fi

PID=$(cat "$PID_FILE")

if [ "$PID" = "$SELF_PID" ] || [ "$PID" = "$PARENT_PID" ]; then
  echo "[SKIP] $NAME protected PID"
  exit 0
fi

if ps -p $PID > /dev/null 2>&1; then
  echo "[STOP] $NAME (PID $PID)"
  kill $PID 2>/dev/null
  sleep 1

  if ps -p $PID > /dev/null 2>&1; then
    echo "[FORCE] $NAME kill -9"
    kill -9 $PID 2>/dev/null
  fi
else
  echo "[SKIP] $NAME not running"
fi

rm -f "$PID_FILE"
echo "[OK] $NAME stopped"
