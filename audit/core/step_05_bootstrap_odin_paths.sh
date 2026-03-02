#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ODIN_HOME="${ODIN_HOME:-$HOME/.odin}"
KEY_DIR="$ODIN_HOME/keys"
LEDGER_DIR="$ODIN_HOME/ledger"
KEY_PATH="${ODIN_KEY_PATH:-$KEY_DIR/authority.key}"
PUB_PATH="${ODIN_PUB_PATH:-$KEY_DIR/authority.pub}"
LEDGER_PATH="${ODIN_LEDGER_PATH:-$LEDGER_DIR/ledger.jsonl}"

mkdir -p "$KEY_DIR" "$LEDGER_DIR"

# If key missing, generate via odin_cli (after we add the command).
# For now, just ensure dirs exist and ledger file exists.
if [[ ! -f "$LEDGER_PATH" ]]; then
  : > "$LEDGER_PATH"
fi

echo "[BOOTSTRAP] ODIN_HOME=$ODIN_HOME"
echo "[BOOTSTRAP] KEY_PATH=$KEY_PATH"
echo "[BOOTSTRAP] PUB_PATH=$PUB_PATH"
echo "[BOOTSTRAP] LEDGER_PATH=$LEDGER_PATH"
echo "[BOOTSTRAP] NOTE: keypair generation will be performed by 'odin_cli keygen' once added."
