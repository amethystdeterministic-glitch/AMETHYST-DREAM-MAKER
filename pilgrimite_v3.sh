#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME/repos/odin_os"
OUTPUT_ROOT="$ROOT/artifacts/pilgrimite_outputs"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$OUTPUT_ROOT/$STAMP"

mkdir -p "$RUN_DIR"

echo "===================================="
echo "PILGRIMITE V3 (CLEAN EXECUTION V4.2)"
echo "===================================="

call_qwen() {
  local PROMPT="$1"

  jq -n --arg p "$PROMPT" '{
    prompt: $p,
    n_predict: 300,
    temperature: 0.2,
    repeat_penalty: 1.3
  }' \
  | curl -s http://localhost:8081/completion \
      -H "Content-Type: application/json" \
      -d @- \
  | jq -r '.content'
}

clean_output() {
  sed -E '
    /---/,$d;
    /AI|prompt|fictional|Note:|To make this|Am I understanding|Yes!/d;
    s/\[.*\]//g;
    /^[[:space:]]*$/d;
  ' \
  | awk '!seen[$0]++' \
  | head -n 15
}

run_acquisition() {
  local OUT="$RUN_DIR/acquisition.txt"

  echo "[RUN] acquisition"

  local PROMPT_MSG1="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a direct LinkedIn message to a fintech fraud lead explaining that Clear-Box AI deterministic pipelines replace black-box models to reduce false positives and reveal fraud clusters proven on 10 million transactions."

  local PROMPT_MSG2="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a concise LinkedIn message explaining that Clear-Box AI provides full auditability, regulatory confidence, and operational control by eliminating black-box AI systems."

  local PROMPT_EMAIL="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a professional email offering Clear-Box AI fraud detection including a proof point of 10 million transactions and 26 fraud clusters identified and propose a 30-minute working session to map the recipient’s fraud pipeline."

  local PROMPT_OFFER="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a clear commercial service offer describing deterministic fraud detection with verifiable decisions, reduced false positives, and full operational control using Clear-Box AI."

  local MSG1
  MSG1=$(call_qwen "$PROMPT_MSG1" | clean_output)

  local MSG2
  MSG2=$(call_qwen "$PROMPT_MSG2" | clean_output)

  local EMAIL
  EMAIL=$(call_qwen "$PROMPT_EMAIL" | clean_output)

  local OFFER
  OFFER=$(call_qwen "$PROMPT_OFFER" | clean_output)

  cat > "$OUT" <<EOT
LinkedIn Message 1:
$MSG1

LinkedIn Message 2:
$MSG2

Email Pitch:
$EMAIL

Service Offer:
$OFFER
EOT

  echo "[DONE] acquisition"
}

run_acquisition

echo "===================================="
echo "PILGRIMITE COMPLETE"
echo "RUN DIR: $RUN_DIR"
echo "===================================="
