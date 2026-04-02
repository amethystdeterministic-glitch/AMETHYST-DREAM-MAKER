#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4C — PIPE RELIABILITY FIX"
echo "===================================="

PIPE=~/repos/odin_os/runtime/signal.pipe

mkdir -p ~/repos/odin_os/runtime

########################################
# ENSURE PIPE EXISTS
########################################
[ -p "$PIPE" ] || mkfifo "$PIPE"

########################################
# FIX SIGNAL COMMAND (FORCE DELIVERY)
########################################
cat > ~/bin/dqi_signal << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

PIPE=~/repos/odin_os/runtime/signal.pipe
SIGNAL="$*"

[ -p "$PIPE" ] || mkfifo "$PIPE"

# force write with background open
(
  echo "$SIGNAL" > "$PIPE"
) &

echo "[SIGNAL SENT] $SIGNAL"
EOS

chmod +x ~/bin/dqi_signal

########################################
# ADD DEBUG VIEW (RAW PIPE CHECK)
########################################
cat > ~/bin/dqi_pipe_watch << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

PIPE=~/repos/odin_os/runtime/signal.pipe

echo "[WATCHING PIPE RAW INPUT]"
cat "$PIPE"
EOS

chmod +x ~/bin/dqi_pipe_watch

echo ""
echo "[DONE] PIPE FIX APPLIED"
echo ""
echo "Test flow:"
echo "  Terminal 1: dqi_pipe_watch"
echo "  Terminal 2: dqi_signal \"test\""
echo "===================================="
