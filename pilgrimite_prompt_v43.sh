#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Injecting HARD STOP into prompts..."

# Rewrite run_acquisition block safely
sed -i '/run_acquisition()/,/^}/c\
run_acquisition() {\
  local OUT="$RUN_DIR/acquisition.txt"\
\
  echo "[RUN] acquisition"\
\
  local BASE="You are Ernesto Lopez, Director of Amethyst Deterministic Ltd (UK). You deliver Clear-Box AI systems with deterministic, verifiable outcomes for regulated industries."\
\
  local MSG1\
  MSG1=$(call_qwen "$BASE Write a concise LinkedIn outreach message (max 120 words) to a fintech fraud lead. Explain that Clear-Box AI replaces black-box models with deterministic pipelines that reduce false positives and surface fraud clusters. Use a confident tone. No repetition. No placeholders. No questions. Plain text only. End immediately after completing the message." | clean_output)\
\
  local MSG2\
  MSG2=$(call_qwen "$BASE Write a second LinkedIn message (max 100 words) focused on auditability, regulatory confidence, and full operational control. Position Clear-Box AI as a replacement for black-box AI. No repetition. No placeholders. No questions. Plain text only. End immediately after completing the message." | clean_output)\
\
  local EMAIL\
  EMAIL=$(call_qwen "$BASE Write a short professional email (max 150 words). Include a concrete proof point such as processing millions of transactions and identifying fraud clusters. Include Clear-Box AI by name. End with a specific call to action proposing a 30-minute working session to map their fraud pipeline. No placeholders. No generic phrases. No questions. Plain text only. End immediately after completing the message." | clean_output)\
\
  local OFFER\
  OFFER=$(call_qwen "$BASE Write a one-paragraph service offer (max 120 words). Focus on deterministic fraud detection, verifiable decisions, reduced false positives, and operational control. Make it sharp, direct, and commercially clear. No repetition. Plain text only. End immediately after completing the message." | clean_output)\
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

echo "[PATCH] HARD STOP ACTIVE"
