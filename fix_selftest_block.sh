#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh"

echo "[FIX] removing broken self-test block..."

# remove entire self:test block (likely corrupted quoting)
sed -i '/SELF-TEST SUITE/,/fi/d' "$TARGET"

echo "[FIX] re-inserting clean self-test block..."

cat <<'CLEAN' >> "$TARGET"

# ================================
# SELF-TEST SUITE (CLEAN)
# ================================

if [ "${1:-}" = "self:test" ]; then
  echo "[SELF-TEST] starting"

  PASS=0
  FAIL=0

  run_test () {
    NAME="$1"
    CMD="$2"
    EXPECT="$3"

    OUT=$(eval "$CMD" 2>/dev/null || true)

    if echo "$OUT" | grep -q "$EXPECT"; then
      echo "[PASS] $NAME"
      PASS=$((PASS+1))
    else
      echo "[FAIL] $NAME"
      FAIL=$((FAIL+1))
    fi
  }

  run_test "deploy allowed" \
    "$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh 'deploy engine test1'" \
    "ENFORCED"

  run_test "status allowed" \
    "$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh 'check system status'" \
    "OK"

  run_test "delete blocked" \
    "$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh 'delete all engines'" \
    "requires_authority"

  run_test "delete allowed ROOT" \
    "$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh 'delete all engines' ROOT" \
    "ENFORCED"

  run_test "dry-run" \
    "$HOME/repos/odin_os/pilgrim_ai_multi_enforce.sh 'deploy engine test2' --dry-run" \
    "SIMULATED"

  echo "[SELF-TEST] PASS: $PASS"
  echo "[SELF-TEST] FAIL: $FAIL"

  if [ "$FAIL" -gt 0 ]; then
    exit 1
  else
    exit 0
  fi
fi

CLEAN

echo "[FIX] done"
