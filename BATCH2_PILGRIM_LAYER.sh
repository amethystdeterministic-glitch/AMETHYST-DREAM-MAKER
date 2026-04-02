#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 2 — PILGRIM ENGINE LAYER"
echo "===================================="

ARTIFACT_ROOT=~/repos/odin_os/artifacts
LEDGER=~/repos/odin_os/ledger.jsonl

########################################
# ENGINE CLASSIFIER (TRUTH BASED)
########################################
cat > ~/repos/odin_os/pilgrim_engines << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

ARTIFACT_ROOT=~/repos/odin_os/artifacts
LEDGER=~/repos/odin_os/ledger.jsonl

echo "===================================="
echo "PILGRIM ENGINES — TRUTH VIEW"
echo "===================================="

for dir in "$ARTIFACT_ROOT"/*_engine; do
  [ -d "$dir" ] || continue

  ENGINE=$(basename "$dir" | sed 's/_engine//')

  FILE_COUNT=$(find "$dir" 2>/dev/null | wc -l)

  LEDGER_MATCH=$(grep -Ri "$ENGINE" $LEDGER 2>/dev/null | head -1)
  FREEZE_MATCH=$(grep -Ri "$ENGINE" $ARTIFACT_ROOT/freeze 2>/dev/null | head -1)

  if [ -z "$LEDGER_MATCH" ]; then
    STATE="INITIALISED"
  elif [ -n "$LEDGER_MATCH" ] && [ -z "$FREEZE_MATCH" ]; then
    STATE="EXECUTED"
  elif [ -n "$LEDGER_MATCH" ] && [ -n "$FREEZE_MATCH" ]; then
    STATE="PROVEN"
  else
    STATE="UNKNOWN"
  fi

  printf "%-25s | %-12s | files: %-5s\n" "$ENGINE" "$STATE" "$FILE_COUNT"

done

echo "===================================="
EOS

chmod +x ~/repos/odin_os/pilgrim_engines
ln -sf ~/repos/odin_os/pilgrim_engines /data/data/com.termux/files/usr/bin/pilgrim_engines

########################################
# REPLACE ODIN_ENGINES (NO MORE FAKE STATES)
########################################
cat > ~/repos/odin_os/odin_engines << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash
pilgrim_engines
EOS

chmod +x ~/repos/odin_os/odin_engines
cp ~/repos/odin_os/odin_engines ~/bin/odin_engines

########################################
# PILGRIM ENTRY COMMAND
########################################
cat > ~/repos/odin_os/pilgrim << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

CMD=$1
ARG=$2

case "$CMD" in

  status)
    odin_status
    ;;

  engines)
    pilgrim_engines
    ;;

  recall)
    pilgrim_recall "$ARG"
    ;;

  run)
    echo "===================================="
    echo "PILGRIM RUN"
    echo "ENGINE: $ARG"
    echo "===================================="

    echo "[NOTE] Execution wiring not yet connected"
    echo "This is next phase (Batch 3)"

    ;;

  *)
    echo "===================================="
    echo "PILGRIM"
    echo "===================================="
    echo "Available commands:"
    echo "  pilgrim status"
    echo "  pilgrim engines"
    echo "  pilgrim recall <engine>"
    echo "  pilgrim run <engine>"
    echo "===================================="
    ;;

esac
EOS

chmod +x ~/repos/odin_os/pilgrim
ln -sf ~/repos/odin_os/pilgrim /data/data/com.termux/files/usr/bin/pilgrim

echo ""
echo "[DONE] BATCH 2 APPLIED"
echo "Try:"
echo "  pilgrim status"
echo "  pilgrim engines"
echo "  pilgrim recall alzheimers"
echo "===================================="
