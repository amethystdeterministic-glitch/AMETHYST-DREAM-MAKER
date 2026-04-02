#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 1 — APPLYING RUNTIME FIX"
echo "===================================="

RUNTIME_DIR=~/repos/odin_os/runtime
mkdir -p $RUNTIME_DIR

########################################
# ODIN STATUS (TRUTH BASED)
########################################
cat > ~/repos/odin_os/odin_status << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "ODIN STATUS (TRUTH)"
echo "===================================="

echo ""
echo "[SYSTEM]"

if pgrep -f "llama-server" > /dev/null; then
  echo "[OK] Qwen running"
else
  echo "[--] Qwen not running"
fi

if pgrep -f "/target/release/dre" > /dev/null; then
  echo "[OK] D.R.E running"
else
  echo "[--] D.R.E not running"
fi

echo ""
echo "[RAW PROCESSES]"
ps -ef | grep -E "llama-server|dre" | grep -v grep

echo ""
echo "===================================="
EOS

chmod +x ~/repos/odin_os/odin_status
ln -sf ~/repos/odin_os/odin_status /data/data/com.termux/files/usr/bin/odin_status

########################################
# ODIN ON (WITH PID CAPTURE)
########################################
cat > ~/repos/odin_os/odin_on << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

RUNTIME_DIR=~/repos/odin_os/runtime
mkdir -p $RUNTIME_DIR

echo "===================================="
echo "ODIN ON — CLEAN BOOT (FIXED)"
echo "===================================="

########################################
# START QWEN (if not running)
########################################
if ! pgrep -f "llama-server" > /dev/null; then
  echo "[START] Qwen"

  /data/data/com.termux/files/usr/bin/llama-server \
    -m ~/odin_runtime/models/qwen2.5-1.5b-instruct-q4_k_m.gguf \
    --host 127.0.0.1 \
    --port 8081 \
    --ctx-size 4096 \
    --n-gpu-layers 0 &

  echo $! > $RUNTIME_DIR/qwen.pid
  sleep 2
else
  echo "[SKIP] Qwen already running"
fi

########################################
# START DRE (if not running)
########################################
if ! pgrep -f "/target/release/dre" > /dev/null; then
  echo "[START] DRE"

  ~/repos/odin_os/target/release/dre &

  echo $! > $RUNTIME_DIR/dre.pid
  sleep 1
else
  echo "[SKIP] DRE already running"
fi

echo ""
echo "[VERIFY]"
pgrep -f "llama-server" >/dev/null && echo "[OK] Qwen running" || echo "[FAIL] Qwen not running"
pgrep -f "/target/release/dre" >/dev/null && echo "[OK] DRE running" || echo "[FAIL] DRE not running"

echo "===================================="
EOS

chmod +x ~/repos/odin_os/odin_on
ln -sf ~/repos/odin_os/odin_on /data/data/com.termux/files/usr/bin/odin_on

########################################
# ODIN OFF (REAL STOP)
########################################
cat > ~/repos/odin_os/odin_off << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

RUNTIME_DIR=~/repos/odin_os/runtime

echo "===================================="
echo "ODIN OFF — VERIFIED SHUTDOWN (FIXED)"
echo "===================================="

########################################
# STOP QWEN
########################################
echo "[STOP] Qwen"

if [ -f $RUNTIME_DIR/qwen.pid ]; then
  PID=$(cat $RUNTIME_DIR/qwen.pid)
  kill $PID 2>/dev/null
fi

pkill -f "llama-server" 2>/dev/null

########################################
# STOP DRE
########################################
echo "[STOP] DRE"

if [ -f $RUNTIME_DIR/dre.pid ]; then
  PID=$(cat $RUNTIME_DIR/dre.pid)
  kill $PID 2>/dev/null
fi

pkill -f "/target/release/dre" 2>/dev/null

########################################
# VERIFY
########################################
sleep 1

echo ""
echo "[VERIFY]"

pgrep -f "llama-server" >/dev/null && echo "[FAIL] Qwen still running" || echo "[OK] Qwen stopped"
pgrep -f "/target/release/dre" >/dev/null && echo "[FAIL] DRE still running" || echo "[OK] DRE stopped"

echo "===================================="
EOS

chmod +x ~/repos/odin_os/odin_off
ln -sf ~/repos/odin_os/odin_off /data/data/com.termux/files/usr/bin/odin_off

echo ""
echo "[DONE] BATCH 1 APPLIED"
echo "Run: odin_on → odin_status → odin_off"
echo "===================================="
