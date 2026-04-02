#!/data/data/com.termux/files/usr/bin/bash

case "$1" in

start)
    echo "[CONTROL] START ORCHESTRATOR"
    nohup ~/repos/odin_os/engines/brca_v19/orchestrator.sh > /dev/null 2>&1 &
    ;;

stop)
    echo "[CONTROL] STOP ORCHESTRATOR"
    pkill -f orchestrator.sh
    ;;

status)
    echo "[CONTROL] STATUS"
    ps aux | grep orchestrator | grep -v grep
    ;;

logs)
    tail -50 ~/repos/odin_os/logs/brca_v19/orchestrator.log
    ;;

check)
    bash ~/repos/odin_os/engines/brca_v19/utils/health_check.sh
    ;;

fail)
    bash ~/repos/odin_os/engines/brca_v19/utils/failure_watch.sh
    ;;

*)
    echo "USAGE:"
    echo "  control.sh start"
    echo "  control.sh stop"
    echo "  control.sh status"
    echo "  control.sh logs"
    echo "  control.sh check"
    echo "  control.sh fail"
    ;;

esac
