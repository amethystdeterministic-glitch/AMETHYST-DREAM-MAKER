#!/data/data/com.termux/files/usr/bin/bash

ROOT=$1

echo "[FINALIZE] START"

# signature hash
SIG_HASH=$(python3 ~/repos/odin_os/engines/brca_v19/utils/signature_hash.py)
echo "$SIG_HASH" > "$ROOT/FREEZE/signature.sha256"

# env capture
bash ~/repos/odin_os/engines/brca_v19/repro/capture_env.sh "$ROOT"

# manifest
python3 ~/repos/odin_os/engines/brca_v19/repro/build_manifest.py "$ROOT"

# proof bundle
python3 - <<PY
from utils.proof_bundle import generate_proof
generate_proof("$ROOT")
PY

# integrity
bash ~/repos/odin_os/engines/brca_v19/utils/build_manifest.sh "$ROOT"

echo "[FINALIZE] COMPLETE"
