#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4G — UNIFY SIGNAL PATH"
echo "===================================="

PIPE="/data/data/com.termux/files/home/.dqi_pipe"

########################################
# ENSURE PIPE EXISTS
########################################
rm -f "$PIPE"
mkfifo "$PIPE"

########################################
# FIX dqi_signal TO MATCH RUNTIME
########################################
cat > ~/bin/dqi_signal << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

PIPE="/data/data/com.termux/files/home/.dqi_pipe"
SIGNAL="$*"

[ -p "$PIPE" ] || mkfifo "$PIPE"

echo "$SIGNAL" > "$PIPE"

echo "[SIGNAL SENT] $SIGNAL"
EOS
chmod +x ~/bin/dqi_signal

########################################
# FIX dqi_log FOR QUICK VIEW
########################################
cat > ~/bin/dqi_log << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash
tail -n 100 ~/repos/odin_os/artifacts/runtime/dqi_runtime.log
EOS
chmod +x ~/bin/dqi_log

########################################
# RESTART RUNTIME CLEAN
########################################
dqi_stop 2>/dev/null
sleep 1
dqi_start

echo ""
echo "[DONE] SIGNAL PATH UNIFIED"
echo "Now run:"
echo "  dqi_signal \"hello unified runtime\""
echo "  dqi_log"
echo "===================================="
