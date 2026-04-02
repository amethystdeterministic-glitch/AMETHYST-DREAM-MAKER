#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT RISK PROJECTION V1"
echo "===================================="

BASE="$HOME/repos/odin_os"
LATEST=$(ls -td "$BASE/artifacts/neocp_"* | grep -v neocp_v2 | head -1)

RAW="$LATEST/neocp_raw.txt"
OUT="$LATEST/neocp_risk_projection.txt"

echo "[STEP] Using dataset: $RAW"

python3 - <<PYTHON
import math

out = open("$OUT", "w")

print("AMETHYST RISK PROJECTION", file=out)
print("====================================", file=out)

for line in open("$RAW"):
    parts = line.split()
    if len(parts) < 10:
        continue

    name = parts[0]

    try:
        ra = float(parts[5])
        dec = float(parts[6])
        obs = float(parts[-4])
        uncert = float(parts[-3])
        motion = float(parts[-2])
        dist = float(parts[-1])
    except:
        continue

    instability = uncert / (obs + 1)
    ratio = motion / (uncert + 1)

    # SKY VECTOR MAGNITUDE
    sky_mag = math.sqrt(ra**2 + dec**2)

    # RISK HEURISTIC
    risk = (instability * (1 / (ratio + 0.01))) * (1 / (dist + 0.01))

    if risk > 5:
        print(f"{name} | risk={risk:.3f} | dist={dist} | instability={instability:.2f} | ratio={ratio:.3f}", file=out)
        print(f"RAW: {line.strip()}", file=out)
        print("", file=out)

out.close()
PYTHON

echo "[STEP] Results:"
cat "$OUT"

echo "===================================="
echo "[SUCCESS] RISK PROJECTION COMPLETE"
echo "===================================="
