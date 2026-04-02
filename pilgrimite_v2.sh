#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
TASK_DIR="$ROOT/tasks"
OUTPUT_ROOT="$ROOT/artifacts/pilgrimite_outputs"
LEDGER_DIR="$ROOT/ledger"
LEDGER_FILE="$LEDGER_DIR/pilgrimite_ledger.jsonl"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$OUTPUT_ROOT/$STAMP"

mkdir -p "$TASK_DIR" "$RUN_DIR" "$LEDGER_DIR"

echo "===================================="
echo "PILGRIMITE V2 SAFE MODE"
echo "===================================="

# -----------------------------
# ENSURE TASK FILES (SIMPLE)
# -----------------------------
ensure_tasks() {
  for ROLE in social strategy ops; do
    FILE="$TASK_DIR/${ROLE}_tasks.json"

    if [ ! -f "$FILE" ]; then
      echo "[INIT] creating $ROLE tasks"

      cat > "$FILE" <<EOT
[
  {"id":"${ROLE}_1","task":"Initial task 1","status":"pending"},
  {"id":"${ROLE}_2","task":"Initial task 2","status":"pending"}
]
EOT
    fi
  done
}

# -----------------------------
# QWEN CALL (SAFE)
# -----------------------------
call_qwen() {
  PROMPT="$1"

  JSON=$(jq -n --arg p "$PROMPT" \
    '{prompt: $p, n_predict: 200, temperature: 0.2}')

  echo "[QWEN] request..."

  curl --max-time 20 -s http://localhost:8081/completion -H "Content-Type: application/json" -d "$JSON" \
    || echo "QWEN_TIMEOUT"
}

# -----------------------------
# LEDGER (MINIMAL SAFE)
# -----------------------------
append_ledger() {
  NAME="$1"
  FILE="$2"

  HASH=$(sha256sum "$FILE" | awk '{print $1}')

  echo "{\"timestamp\":\"$STAMP\",\"pilgrimite\":\"$NAME\",\"hash\":\"$HASH\"}" >> "$LEDGER_FILE"
}

# -----------------------------
# MARK COMPLETE
# -----------------------------
complete_tasks() {
  FILE="$1"

  jq 'map(.status="completed")' "$FILE" > "${FILE}.tmp"
  mv "${FILE}.tmp" "$FILE"
}

# -----------------------------
# RUN
# -----------------------------
run_role() {
  NAME="$1"
  TASK_FILE="$TASK_DIR/${NAME}_tasks.json"
  OUT_FILE="$RUN_DIR/${NAME}.txt"

  echo "[RUN] $NAME"

  TASKS=$(jq -c '.' "$TASK_FILE")

  PROMPT="Execute these tasks clearly: $TASKS"

  RESPONSE=$(call_qwen "$PROMPT")

  echo "$RESPONSE" > "$OUT_FILE"

  complete_tasks "$TASK_FILE"
  append_ledger "$NAME" "$OUT_FILE"

  echo "[DONE] $NAME"
}

# -----------------------------
# EXECUTION
# -----------------------------
ensure_tasks

run_role social
run_role strategy
run_role ops

echo "===================================="
echo "PILGRIMITE V2 SAFE COMPLETE"
echo "RUN DIR: $RUN_DIR"
echo "===================================="
