#!/data/data/com.termux/files/usr/bin/bash

RECEIPT=~/repos/odin_os/artifacts/discovery_receipts/GW150914_CHIRP_RECEIPT.json

echo "===================================="
echo "CHIRP ENGINE — EXECUTION"
echo "===================================="

if [ ! -f "$RECEIPT" ]; then
  echo "[FAIL] Receipt not found"
  exit 1
fi

echo "[LOAD] Chirp receipt"
cat $RECEIPT

HASH=$(sha256sum $RECEIPT | cut -d ' ' -f1)

echo "[LEDGER] hash=$HASH"
echo "[STATUS] Chirp execution complete"
