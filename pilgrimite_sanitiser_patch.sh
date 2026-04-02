#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Adding output sanitisation layer..."

# Inject clean_output function before run_acquisition
sed -i '/run_acquisition()/i\
clean_output() {\
  sed -E '\''\
    /---/,$d; \
    /AI|prompt|fictional|not a real person/d; \
    s/\[.*\]//g; \
    /^[[:space:]]*$/d;\
  '\''\
}' "$FILE"

# Apply cleaning to all outputs
sed -i 's|MSG1=$(call_qwen .*|MSG1=$(call_qwen "$BASE Write a concise LinkedIn outreach message (max 120 words) to a fintech fraud lead. Explain that Clear-Box AI replaces black-box models with deterministic pipelines that reduce false positives and surface fraud clusters. Use a confident tone. No repetition. No placeholders. No questions. Plain text only." | clean_output)|' "$FILE"

sed -i 's|MSG2=$(call_qwen .*|MSG2=$(call_qwen "$BASE Write a second LinkedIn message (max 100 words) focused on auditability, regulatory confidence, and full operational control. Position Clear-Box AI as a replacement for black-box AI. No repetition. No placeholders. No questions. Plain text only." | clean_output)|' "$FILE"

sed -i 's|EMAIL=$(call_qwen .*|EMAIL=$(call_qwen "$BASE Write a short professional email (max 150 words). Include a concrete proof point such as processing millions of transactions and identifying fraud clusters. Include Clear-Box AI by name. End with a specific call to action proposing a 30-minute working session to map their fraud pipeline. No placeholders. No generic phrases. No questions. Plain text only." | clean_output)|' "$FILE"

sed -i 's|OFFER=$(call_qwen .*|OFFER=$(call_qwen "$BASE Write a one-paragraph service offer (max 120 words). Focus on deterministic fraud detection, verifiable decisions, reduced false positives, and operational control. Make it sharp, direct, and commercially clear. No repetition. Plain text only." | clean_output)|' "$FILE"

echo "[PATCH] SANITISER ACTIVE"
