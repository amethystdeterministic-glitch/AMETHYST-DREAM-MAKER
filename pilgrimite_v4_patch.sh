#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Applying V4 output control + repetition fix..."

# -----------------------------
# Upgrade call_qwen (repeat penalty)
# -----------------------------
sed -i '/call_qwen()/,/^}/c\
call_qwen() {\
  PROMPT="$1"\
  jq -n --arg p "$PROMPT" '\''{prompt: $p, n_predict: 300, temperature: 0.2, repeat_penalty: 1.3}'\'' \
  | curl -s http://localhost:8081/completion \
      -H "Content-Type: application/json" \
      -d @- \
  | jq -r '\''.content'\''\
}' "$FILE"

# -----------------------------
# Replace BASE (strong identity)
# -----------------------------
sed -i 's|BASE=.*|BASE="You are Ernesto Lopez, Director of Amethyst Deterministic Ltd (UK). You deliver Clear-Box AI systems with deterministic, verifiable outcomes for regulated industries."|' "$FILE"

# -----------------------------
# Replace LinkedIn Message 1
# -----------------------------
sed -i 's|MSG1=.*|MSG1=$(call_qwen "$BASE Write a concise LinkedIn outreach message (max 120 words) to a fintech fraud lead. Explain that Clear-Box AI replaces black-box models with deterministic pipelines that reduce false positives and surface fraud clusters. Use a confident tone. No repetition. No placeholders. No questions. Plain text only.")|' "$FILE"

# -----------------------------
# Replace LinkedIn Message 2
# -----------------------------
sed -i 's|MSG2=.*|MSG2=$(call_qwen "$BASE Write a second LinkedIn message (max 100 words) focused on auditability, regulatory confidence, and full operational control. Position Clear-Box AI as a replacement for black-box AI. No repetition. No placeholders. No questions. Plain text only.")|' "$FILE"

# -----------------------------
# Replace EMAIL (with proof + CTA)
# -----------------------------
sed -i 's|EMAIL=.*|EMAIL=$(call_qwen "$BASE Write a short professional email (max 150 words). Include: \
- a concrete proof point (e.g. processing millions of transactions and identifying fraud clusters), \
- Clear-Box AI by name, \
- a specific call to action: propose a 30-minute working session to map their fraud pipeline. \
No placeholders. No generic phrases. No questions. Plain text only.")|' "$FILE"

# -----------------------------
# Replace OFFER (tight + sellable)
# -----------------------------
sed -i 's|OFFER=.*|OFFER=$(call_qwen "$BASE Write a one-paragraph service offer (max 120 words). Focus on: deterministic fraud detection, verifiable decisions, reduced false positives, and operational control. Make it sharp, direct, and commercially clear. No repetition. Plain text only.")|' "$FILE"

echo "[PATCH] V4 COMPLETE"
