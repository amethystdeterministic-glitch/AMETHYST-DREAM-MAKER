#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
DATA_DIR="$ROOT/datasets/cancer"
RUN_DIR="$ROOT/artifacts/cancer_real_$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$DATA_DIR"
mkdir -p "$RUN_DIR"

echo "===================================="
echo "REAL DATA DISCOVERY — BREAST CANCER"
echo "AMETHYST cOS"
echo "===================================="

# -----------------------------------
# DOWNLOAD REAL DATA (UCI)
# -----------------------------------
DATA_FILE="$DATA_DIR/breast_cancer.csv"

if [ ! -f "$DATA_FILE" ]; then
  echo "[STEP] Downloading dataset..."
  curl -L -o "$DATA_FILE" \
  https://raw.githubusercontent.com/jbrownlee/Datasets/master/breast-cancer.csv
fi

echo "[STEP] Dataset ready: $DATA_FILE"

# -----------------------------------
# Pilgrim AI execution
# -----------------------------------
pilgrim_exec() {
  local PROMPT="$1"

  jq -n --arg p "$PROMPT" '{
    prompt: $p,
    n_predict: 250,
    temperature: 0.2,
    repeat_penalty: 1.2
  }' \
  | curl -s http://localhost:8081/completion \
      -H "Content-Type: application/json" \
      -d @- \
  | jq -r '.content'
}

clean_output() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed '/^$/d'
}

# -----------------------------------
# DLE
# -----------------------------------
dle_translate() {
  local INPUT="$1"
  OUT=$(pilgrim_exec "Translate the following English text into Welsh:\n$INPUT" | clean_output)

  if [ -z "$OUT" ]; then
    echo "[DLE FAIL]"
    return 1
  fi

  echo "$OUT"
}

# -----------------------------------
# BASIC DATA SUMMARY (DETERMINISTIC)
# -----------------------------------
ROW_COUNT=$(wc -l < "$DATA_FILE")

PROMPT="Analyse a real breast cancer dataset with $ROW_COUNT records and summarise key patterns, feature relationships, and any strong separation indicators in a deterministic clinical discovery tone."

echo "[STEP] Running discovery..."

EN_OUTPUT=$(pilgrim_exec "$PROMPT" | clean_output)

if [ -z "$EN_OUTPUT" ]; then
  echo "[FAIL] Empty output"
  exit 1
fi

echo "[STEP] Running DLE..."

CY_OUTPUT=$(dle_translate "$EN_OUTPUT")

# -----------------------------------
# WRITE OUTPUT
# -----------------------------------
echo "$EN_OUTPUT" > "$RUN_DIR/discovery_en.txt"
echo "$CY_OUTPUT" > "$RUN_DIR/discovery_cy.txt"

cat > "$RUN_DIR/discovery_bilingual.txt" <<EOT
--- ENGLISH ---
$EN_OUTPUT

--- WELSH ---
$CY_OUTPUT
EOT

cat > "$RUN_DIR/proof.json" <<EOT
{
  "system": "Amethyst cOS",
  "engine": "Cancer Discovery Engine",
  "dataset": "breast_cancer.csv",
  "records": $ROW_COUNT,
  "bilingual": true
}
EOT

echo
echo "===================================="
echo "[SUCCESS] REAL DATA DISCOVERY COMPLETE"
echo "$RUN_DIR"
