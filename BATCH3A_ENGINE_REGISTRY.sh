#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 3A — ENGINE REGISTRY (TRUTH)"
echo "===================================="

REG_PATH=~/repos/odin_os/artifacts/registry
mkdir -p $REG_PATH

if [ ! -f $REG_PATH/ENGINE_REGISTRY.json ]; then

cat > $REG_PATH/ENGINE_REGISTRY.json << 'EOS'
{
  "alzheimers": { "status": "initialised" },
  "dle": { "status": "active" },
  "flipper": { "status": "concept" },
  "godot": { "status": "external" },
  "creator": { "status": "partial" },
  "business": { "status": "partial" }
}
EOS

echo "[OK] registry created"

else
echo "[SKIP] registry already exists"
fi

cat > ~/repos/odin_os/pilgrim_engines << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash

ARTIFACT_ROOT=~/repos/odin_os/artifacts
LEDGER=~/repos/odin_os/ledger.jsonl
REGISTRY=~/repos/odin_os/artifacts/registry/ENGINE_REGISTRY.json

echo "===================================="
echo "PILGRIM ENGINES — FULL TRUTH"
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

  printf "%-20s | %-12s | artifact | files: %-5s\n" "$ENGINE" "$STATE" "$FILE_COUNT"
done

if [ -f "$REGISTRY" ]; then
  echo "------------------------------------"
  echo "[REGISTRY ENGINES]"

  grep -o '"[^"]*": {[^}]*}' $REGISTRY | while read line; do
    NAME=$(echo $line | cut -d '"' -f2)
    STATUS=$(echo $line | grep -o '"status": "[^"]*"' | cut -d '"' -f4)

    if [ -d "$ARTIFACT_ROOT/${NAME}_engine" ]; then
      continue
    fi

    printf "%-20s | %-12s | registry\n" "$NAME" "$STATUS"
  done
fi

echo "===================================="
EOS

chmod +x ~/repos/odin_os/pilgrim_engines
cp ~/repos/odin_os/pilgrim_engines ~/bin/pilgrim_engines

echo "[DONE] REGISTRY ACTIVE"
