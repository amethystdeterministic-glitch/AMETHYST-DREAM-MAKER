#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT ANOMALY SCANNER V1"
echo "===================================="

BASE="$HOME/repos/odin_os"

# USE ORIGINAL NEOCP INGEST (NOT V2)
LATEST=$(ls -td "$BASE/artifacts/neocp_"* | grep -v neocp_v2 | head -1)

if [ -z "${LATEST:-}" ]; then
    echo "[FAIL] No NEOCP raw artifact found"
    exit 1
fi

RAW="$LATEST/neocp_raw.txt"
OUT="$LATEST/neocp_anomalies.txt"

echo "[STEP] Using dataset: $RAW"

python3 - <<PYTHON
import math

out = open("$OUT", "w")

print("AMETHYST ANOMALY REPORT", file=out)
print("====================================", file=out)

with open("$RAW") as f:
    for line in f:
        parts = line.split()
        if len(parts) < 10:
            continue

        name = parts[0]

        try:
            obs = float(parts[-4])
            uncert = float(parts[-3])
            motion = float(parts[-2])
        except:
            continue

        instability = uncert / (obs + 1)
        ratio = motion / (uncert + 1)

        if instability > 1.5 or ratio < 0.2:
            score = instability * (1 / (ratio + 0.01))

            print(f"{name} | instability={instability:.3f} | ratio={ratio:.5f} | score={score:.3f}", file=out)
            print(f"RAW: {line.strip()}", file=out)
            print("", file=out)

out.close()
PYTHON

echo "[STEP] Results:"
cat "$OUT"

echo "===================================="
echo "[SUCCESS] ANOMALY SCAN COMPLETE"
echo "===================================="
