#!/data/data/com.termux/files/usr/bin/bash

REGISTRY="/data/data/com.termux/files/home/repos/odin_os/core/engine_registry_live.json"
TMP="/data/data/com.termux/files/home/repos/odin_os/core/engine_registry_live.tmp.json"

jq '
.auto_registered |= map(
  if .engine_id == "PI_RUNNER" then
    .health_check = "pgrep -f core/operator/pi_runner/start.sh"
  else
    .
  end
)
' "$REGISTRY" > "$TMP"

mv "$TMP" "$REGISTRY"

echo "[OK] PI_RUNNER health_check fixed"
