#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4A — RUNTIME SERVICE"
echo "===================================="

RUNTIME_LOG=~/repos/odin_os/artifacts/runtime/dqi_runtime.log
RUNTIME_PID=~/repos/odin_os/runtime/dqi.pid

mkdir -p ~/repos/odin_os/artifacts/runtime
mkdir -p ~/repos/odin_os/runtime

########################################
# START RUNTIME (BACKGROUND)
########################################
cat > ~/bin/dqi_start << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

RUNTIME_LOG=~/repos/odin_os/artifacts/runtime/dqi_runtime.log
RUNTIME_PID=~/repos/odin_os/runtime/dqi.pid

if [ -f "$RUNTIME_PID" ]; then
  echo "[SKIP] Runtime already running"
  exit 0
fi

echo "[START] DQI runtime (background)"

nohup ~/repos/odin_os/target/debug/dqi_v1 > "$RUNTIME_LOG" 2>&1 &

echo $! > "$RUNTIME_PID"

echo "[OK] Runtime started"
echo "PID: $(cat $RUNTIME_PID)"
EOS

chmod +x ~/bin/dqi_start

########################################
# STOP RUNTIME
########################################
cat > ~/bin/dqi_stop << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

RUNTIME_PID=~/repos/odin_os/runtime/dqi.pid

if [ ! -f "$RUNTIME_PID" ]; then
  echo "[SKIP] No runtime PID"
  exit 0
fi

PID=$(cat $RUNTIME_PID)

kill $PID 2>/dev/null

rm -f $RUNTIME_PID

echo "[OK] Runtime stopped"
EOS

chmod +x ~/bin/dqi_stop

########################################
# SEND SIGNAL (NO NEW TERMINAL NEEDED)
########################################
cat > ~/bin/dqi_signal << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

SIGNAL="$*"
PIPE=~/repos/odin_os/runtime/signal.pipe

mkdir -p ~/repos/odin_os/runtime

# create pipe if missing
[ -p "$PIPE" ] || mkfifo "$PIPE"

echo "$SIGNAL" > "$PIPE"

echo "[SIGNAL SENT] $SIGNAL"
EOS

chmod +x ~/bin/dqi_signal

########################################
# VIEW OUTPUT
########################################
cat > ~/bin/dqi_log << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

tail -n 50 -f ~/repos/odin_os/artifacts/runtime/dqi_runtime.log
EOS

chmod +x ~/bin/dqi_log

echo ""
echo "[DONE] RUNTIME SERVICE READY"
echo ""
echo "Commands:"
echo "  dqi_start"
echo "  dqi_signal \"Explore new decision pathways\""
echo "  dqi_signal \"Find market leads\""
echo "  dqi_log"
echo "  dqi_stop"
echo "===================================="
