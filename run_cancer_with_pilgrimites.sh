#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
DATA="$ROOT/datasets/cancer/breast_cancer.csv"
RUN_DIR="$ROOT/artifacts/cancer_guarded_$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$RUN_DIR"

echo "===================================="
echo "DETERMINISTIC DISCOVERY (GUARDED)"
echo "===================================="

fail() {
  echo "[FAIL] $1"
  exit 1
}

# -----------------------------------
# PILGRIMITE: INGEST GUARD
# -----------------------------------
echo "[IngestGuard] Checking dataset..."

[ -f "$DATA" ] || fail "Dataset missing"

ROW_COUNT=$(wc -l < "$DATA")
[ "$ROW_COUNT" -gt 0 ] || fail "Dataset empty"

echo "[IngestGuard] OK ($ROW_COUNT rows)"

# -----------------------------------
# PILGRIMITE: METRIC GUARD
# -----------------------------------
echo "[MetricGuard] Computing metrics..."

awk -F',' '
{
  for(i=2;i<=NF;i++){
    sum[i]+=$i
  }
}
END{
  for(i=2;i<=NF;i++){
    val=sum[i]/NR
    if(val=="nan" || val=="") exit 1
    print "Feature_" i ": " val
  }
}
' "$DATA" > "$RUN_DIR/feature_means.txt" || fail "Metric computation failed"

echo "[MetricGuard] OK"

# -----------------------------------
# BUILD PROMPT
# -----------------------------------
METRICS=$(cat "$RUN_DIR/feature_means.txt")

PROMPT="Using deterministic clinical metrics:\n$METRICS\n\nProvide a concise discovery summary."

# -----------------------------------
# Pilgrim AI
# -----------------------------------
pilgrim_exec() {
  jq -n --arg p "$PROMPT" '{
    prompt: $p,
    n_predict: 200,
    temperature: 0.2
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
# PILGRIMITE: DISCOVERY GUARD
# -----------------------------------
echo "[DiscoveryGuard] Generating..."

EN_OUTPUT=$(pilgrim_exec | clean_output)

[ -n "$EN_OUTPUT" ] || fail "Empty discovery output"

if echo "$EN_OUTPUT" | grep -qiE "translate|instruction|you are"; then
  fail "Prompt leakage detected"
fi

echo "[DiscoveryGuard] OK"

# -----------------------------------
# PILGRIMITE: LANGUAGE GUARD
# -----------------------------------
echo "[LanguageGuard] Translating..."

CY_OUTPUT=$(jq -n --arg p "$EN_OUTPUT" '{
  prompt: "Translate to Welsh:\n" + $p,
  n_predict: 200
}' | curl -s http://localhost:8081/completion \
    -H "Content-Type: application/json" \
    -d @- \
  | jq -r '.content' | clean_output)

[ -n "$CY_OUTPUT" ] || fail "Empty Welsh output"

if echo "$CY_OUTPUT" | grep -qiE "the|and|with|for"; then
  fail "Welsh validation failed"
fi

echo "[LanguageGuard] OK"

# -----------------------------------
# PILGRIMITE: ARTIFACT GUARD
# -----------------------------------
echo "[ArtifactGuard] Writing outputs..."

echo "$EN_OUTPUT" > "$RUN_DIR/discovery_en.txt"
echo "$CY_OUTPUT" > "$RUN_DIR/discovery_cy.txt"

[ -s "$RUN_DIR/discovery_en.txt" ] || fail "EN file empty"
[ -s "$RUN_DIR/discovery_cy.txt" ] || fail "CY file empty"

echo "[ArtifactGuard] OK"

echo
echo "===================================="
echo "[SUCCESS] GUARDED DISCOVERY COMPLETE"
echo "$RUN_DIR"
