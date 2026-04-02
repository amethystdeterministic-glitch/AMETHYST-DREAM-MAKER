#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Injecting minimal 1.5B prompts..."

sed -i '/run_acquisition()/,/^}/c\
run_acquisition() {\
  local OUT="$RUN_DIR/acquisition.txt"\
\
  echo "[RUN] acquisition"\
\
  local PROMPT_MSG1="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a direct LinkedIn message to a fintech fraud lead explaining that Clear-Box AI deterministic pipelines replace black-box models to reduce false positives and reveal fraud clusters proven on 10 million transactions."\
\
  local PROMPT_MSG2="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a concise LinkedIn message explaining that Clear-Box AI provides full auditability, regulatory confidence, and operational control by eliminating black-box AI systems."\
\
  local PROMPT_EMAIL="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a professional email offering Clear-Box AI fraud detection including a proof point of 10 million transactions and 26 fraud clusters identified and propose a 30-minute working session to map the recipient’s fraud pipeline."\
\
  local PROMPT_OFFER="Ernesto Lopez, Director of Amethyst Deterministic Ltd in Cardiff UK, write a clear commercial service offer describing deterministic fraud detection with verifiable decisions, reduced false positives, and full operational control using Clear-Box AI."\
\
  local MSG1\
  MSG1=$(call_qwen "$PROMPT_MSG1" | clean_output)\
\
  local MSG2\
  MSG2=$(call_qwen "$PROMPT_MSG2" | clean_output)\
\
  local EMAIL\
  EMAIL=$(call_qwen "$PROMPT_EMAIL" | clean_output)\
\
  local OFFER\
  OFFER=$(call_qwen "$PROMPT_OFFER" | clean_output)\
\
  cat > "$OUT" <<EOT\
LinkedIn Message 1:\
$MSG1\
\
LinkedIn Message 2:\
$MSG2\
\
Email Pitch:\
$EMAIL\
\
Service Offer:\
$OFFER\
EOT\
\
  echo "[DONE] acquisition"\
}' "$FILE"

echo "[PATCH] PROMPTS UPDATED FOR 1.5B"
