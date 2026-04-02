#!/data/data/com.termux/files/usr/bin/bash

NAME=$1
shift

BASE=~/repos/odin_os
PID_FILE=$BASE/runtime/pids/${NAME}.pid
LOG_FILE=$BASE/logs/${NAME}.log

echo "[START] $NAME"

nohup "$@" > "$LOG_FILE" 2>&1 &
PID=$!

sleep 1

if ps -p $PID > /dev/null 2>&1; then
  echo $PID > "$PID_FILE"
  echo "[OK] $NAME running (PID $PID)"
else
  echo "[ERROR] $NAME failed to start"
  exit 1
fi
