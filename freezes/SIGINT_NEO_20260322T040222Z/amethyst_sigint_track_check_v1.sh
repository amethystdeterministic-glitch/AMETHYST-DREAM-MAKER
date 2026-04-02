#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT TRACK CONSISTENCY V1"
echo "===================================="

BASE="$HOME/repos/odin_os"
LATEST=$(ls -td "$BASE/artifacts"/neocp_* | head -1)
RAW="$LATEST/neocp_raw.txt"

TARGET="P12kfD7"

echo "[STEP] Extracting target..."
LINE=$(grep "$TARGET" "$RAW")

echo "[RAW]"
echo "$LINE"
echo

python3 - <<PYTHON
import math

line = """$LINE"""
parts = line.split()

ra = float(parts[5])
dec = float(parts[6])
motion = float(parts[-2])
uncert = float(parts[-3])
obs = float(parts[-4])

# --- derived signals ---
sky_position_magnitude = math.sqrt(ra**2 + dec**2)

# normalized instability score
instability = uncert / (obs + 1)

# motion vs uncertainty mismatch
motion_uncert_ratio = motion / (uncert + 1)

print("====================================")
print("DERIVED SIGNALS")
print("====================================")
print(f"Sky magnitude: {sky_position_magnitude:.3f}")
print(f"Instability score: {instability:.3f}")
print(f"Motion/Uncertainty ratio: {motion_uncert_ratio:.5f}")

print()
print("INTERPRETATION")
print("====================================")

if instability > 2:
    print("HIGH INSTABILITY DETECTED")
else:
    print("Normal stability")

if motion_uncert_ratio < 0.2:
    print("Trajectory poorly constrained")
else:
    print("Trajectory consistent")
PYTHON

echo "===================================="
echo "[DONE]"
echo "===================================="
