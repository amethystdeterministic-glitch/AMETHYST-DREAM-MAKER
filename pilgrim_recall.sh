#!/data/data/com.termux/files/usr/bin/bash

QUERY=$1
ARTIFACT_ROOT=~/repos/odin_os/artifacts
LEDGER=~/repos/odin_os/ledger.jsonl

echo "===================================="
echo "PILGRIM KNOWS — RECALL"
echo "QUERY: $QUERY"
echo "===================================="

echo ""
echo "[SUMMARY]"

ENGINE_PATH=$(grep -Ri "$QUERY" $ARTIFACT_ROOT/registry 2>/dev/null | grep "path" | head -1 | cut -d '"' -f4)

if [ -n "$ENGINE_PATH" ]; then
  echo "ENGINE: $QUERY"
  echo "PATH: $ENGINE_PATH"

  # Count files (activity signal)
  FILE_COUNT=$(find "$ENGINE_PATH" 2>/dev/null | wc -l)
  echo "ARTIFACTS: $FILE_COUNT files"

  # Last modified (recency)
  LAST_UPDATE=$(find "$ENGINE_PATH" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
  if [ -n "$LAST_UPDATE" ]; then
    LAST_DATE=$(date -d @"${LAST_UPDATE%.*}" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
    echo "LAST UPDATED: $LAST_DATE"
  else
    echo "LAST UPDATED: UNKNOWN"
  fi

  # Heuristic status
  if [ "$FILE_COUNT" -gt 50 ]; then
    echo "STATUS: ACTIVE / DEVELOPED"
  elif [ "$FILE_COUNT" -gt 10 ]; then
    echo "STATUS: PARTIAL"
  else
    echo "STATUS: INITIALISED"
  fi

else
  echo "UNKNOWN — NO ENGINE PATH FOUND"
fi

# Ledger presence
LEDGER_MATCH=$(grep -Ri "$QUERY" $LEDGER 2>/dev/null | tail -1)
if [ -n "$LEDGER_MATCH" ]; then
  echo "LEDGER: PRESENT"
else
  echo "LEDGER: NO RECORDED EXECUTION"
fi

# Freeze presence
FREEZE_MATCH=$(grep -Ri "$QUERY" $ARTIFACT_ROOT/freeze 2>/dev/null | head -1)
if [ -n "$FREEZE_MATCH" ]; then
  echo "PROOF: FREEZE LINKED"
else
  echo "PROOF: NO FREEZE FOUND"
fi

echo "------------------------------------"

echo ""
echo "[MATCHING ARTIFACTS]"
grep -Ri "$QUERY" $ARTIFACT_ROOT 2>/dev/null | head -20

echo ""
echo "[MATCHING LEDGER ENTRIES]"
grep -Ri "$QUERY" $LEDGER 2>/dev/null | tail -5

echo ""
echo "[MATCHING ENGINES]"
grep -Ri "$QUERY" ~/repos/odin_os/engines 2>/dev/null | head -10

echo "===================================="
