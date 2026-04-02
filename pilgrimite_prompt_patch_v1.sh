#!/usr/bin/env bash
set -euo pipefail

FILE="$HOME/repos/odin_os/pilgrimite_v3.sh"

echo "[PATCH] Applying HARD TEXT-ONLY PROMPT ENFORCEMENT..."

# Replace BASE definition
sed -i 's|BASE=.*|BASE="You are Ernesto Lopez, Director of Amethyst Deterministic Ltd in the UK. You provide deterministic AI systems with verifiable outcomes."|' "$FILE"

# Replace MSG1
sed -i 's|MSG1=.*|MSG1=$(call_qwen "$BASE Write a LinkedIn outreach message to a fintech fraud lead explaining deterministic AI pipelines that reduce fraud and false positives. No questions. No placeholders. Do NOT output JSON. Do NOT use braces. Only plain text.")|' "$FILE"

# Replace MSG2
sed -i 's|MSG2=.*|MSG2=$(call_qwen "$BASE Write a second LinkedIn message focused on control, auditability, and removal of black-box AI behaviour. No questions. No placeholders. Do NOT output JSON. Only plain text.")|' "$FILE"

# Replace EMAIL
sed -i 's|EMAIL=.*|EMAIL=$(call_qwen "$BASE Write a short professional email offering deterministic AI fraud detection systems. Include subject line. No placeholders. Do NOT output JSON. Only plain text.")|' "$FILE"

# Replace OFFER
sed -i 's|OFFER=.*|OFFER=$(call_qwen "$BASE Write a one-paragraph service offer focused on fraud detection, verifiable decisions, and operational reliability. Do NOT output JSON. Only plain text.")|' "$FILE"

echo "[PATCH] COMPLETE"
