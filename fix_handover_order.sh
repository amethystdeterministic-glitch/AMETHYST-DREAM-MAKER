#!/data/data/com.termux/files/usr/bin/bash
set -e

ODIN_OFF="$HOME/repos/odin_os/odin_off"

# Move qwen_off BEFORE handover write
sed -i '/Handover written/ i\
bash ~/repos/odin_os/qwen_off.sh\
' "$ODIN_OFF"

echo "[OK] qwen shutdown moved before handover snapshot"
