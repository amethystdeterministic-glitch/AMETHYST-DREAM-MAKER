#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "FIXING PILGRIM COMMAND LAYER"
echo "===================================="

########################################
# REMOVE OLD BROKEN PILGRIM LINK
########################################
rm -f ~/bin/pilgrim 2>/dev/null

########################################
# CREATE NEW PILGRIM COMMAND (SAFE NAME)
########################################
cat > ~/repos/odin_os/pilgrim_cmd << 'EOS'
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
    echo "[NEXT] Batch 3 will wire execution"
    ;;

  *)
    echo "===================================="
    echo "PILGRIM CMD"
    echo "===================================="
    echo "Commands:"
    echo "  pilgrim_cmd status"
    echo "  pilgrim_cmd engines"
    echo "  pilgrim_cmd recall <engine>"
    echo "  pilgrim_cmd run <engine>"
    echo "===================================="
    ;;

esac
EOS

chmod +x ~/repos/odin_os/pilgrim_cmd
cp ~/repos/odin_os/pilgrim_cmd ~/bin/pilgrim_cmd
chmod +x ~/bin/pilgrim_cmd

echo ""
echo "[OK] pilgrim_cmd ready"
echo "===================================="
