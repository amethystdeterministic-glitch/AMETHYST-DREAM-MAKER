#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
PILGRIMITE_DIR="$ROOT/pilgrimites"
TASK_DIR="$ROOT/tasks"
OUTPUT_DIR="$ROOT/artifacts/pilgrimite_outputs"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$PILGRIMITE_DIR/social"
mkdir -p "$PILGRIMITE_DIR/strategy"
mkdir -p "$PILGRIMITE_DIR/ops"

mkdir -p "$TASK_DIR"
mkdir -p "$OUTPUT_DIR/$STAMP"

echo "===================================="
echo "PILGRIMITE V1 INITIALISING"
echo "===================================="

# -----------------------------
# DEFAULT TASK FILES
# -----------------------------
if [ ! -f "$TASK_DIR/social_tasks.json" ]; then
cat > "$TASK_DIR/social_tasks.json" <<EOT
[
  "Generate 3 TikTok script ideas aligned with Mister Seventy Six tone",
  "Refine 1 idea into a strong opening hook"
]
EOT
fi

if [ ! -f "$TASK_DIR/strategy_tasks.json" ]; then
cat > "$TASK_DIR/strategy_tasks.json" <<EOT
[
  "Identify one monetisation opportunity for deterministic AI",
  "Draft a short outreach angle for potential partners"
]
EOT
fi

if [ ! -f "$TASK_DIR/ops_tasks.json" ]; then
cat > "$TASK_DIR/ops_tasks.json" <<EOT
[
  "List current system capabilities",
  "List next 3 executable priorities"
]
EOT
fi

# -----------------------------
# SAFE QWEN CALL
# -----------------------------
call_qwen() {
  PROMPT="$1"

  JSON=$(jq -n --arg p "$PROMPT" \
    '{prompt: $p, n_predict: 300, temperature: 0.2}')

  curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d "$JSON"
}

# -----------------------------
# EXECUTE PILGRIMITE
# -----------------------------
run_pilgrimite() {
  NAME="$1"
  TASK_FILE="$TASK_DIR/${NAME}_tasks.json"
  OUTPUT_FILE="$OUTPUT_DIR/$STAMP/${NAME}_output.txt"

  echo "[RUN] $NAME"

  TASKS=$(jq -c . "$TASK_FILE")

  PROMPT="You are the ${NAME} Pilgrimite. Execute all tasks clearly and deterministically. Return useful outputs.

Tasks:
$TASKS"

  RESULT=$(call_qwen "$PROMPT")

  echo "==================================" >> "$OUTPUT_FILE"
  echo "PILGRIMITE: $NAME" >> "$OUTPUT_FILE"
  echo "TIMESTAMP: $STAMP" >> "$OUTPUT_FILE"
  echo "==================================" >> "$OUTPUT_FILE"
  echo "$RESULT" >> "$OUTPUT_FILE"
  echo >> "$OUTPUT_FILE"

  echo "[DONE] $NAME → $OUTPUT_FILE"
}

# -----------------------------
# RUN ALL
# -----------------------------
run_pilgrimite "social"
run_pilgrimite "strategy"
run_pilgrimite "ops"

echo "===================================="
echo "PILGRIMITE RUN COMPLETE"
echo "OUTPUT: $OUTPUT_DIR/$STAMP"
echo "===================================="
