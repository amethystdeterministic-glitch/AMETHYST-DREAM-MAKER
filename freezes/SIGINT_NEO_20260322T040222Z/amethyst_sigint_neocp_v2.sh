#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT NEOCP ENGINE V2"
echo "===================================="

BASE="$HOME/repos/odin_os"
LATEST=$(ls -td "$BASE/artifacts"/neocp_* | head -1)
OUT="$BASE/artifacts/neocp_v2_$(date -u +%Y%m%dT%H%M%SZ)"

mkdir -p "$OUT"

echo "[STEP] Using source: $LATEST"

RAW="$LATEST/neocp_raw.txt"
PARSED="$OUT/neocp_parsed.csv"
RANKED="$OUT/neocp_ranked.txt"

echo "[STEP] Parsing structured fields..."

python3 - <<PYTHON
import re

rows = []

with open("$RAW") as f:
    for line in f:
        parts = line.split()
        if len(parts) < 12:
            continue

        try:
            obj = parts[0]
            score = float(parts[1])
            year = int(parts[2])
            month = int(parts[3])
            day = float(parts[4])
            ra = float(parts[5])
            dec = float(parts[6])
            mag = float(parts[7])

            # tail values (more stable)
            obs = float(parts[-4])
            uncert = float(parts[-3])
            motion = float(parts[-2])
            extra = float(parts[-1])

            rows.append((obj, score, ra, dec, mag, obs, uncert, motion, extra))
        except:
            continue

with open("$PARSED", "w") as out:
    out.write("obj,score,ra,dec,mag,obs,uncert,motion,extra\n")
    for r in rows:
        out.write(",".join(map(str, r)) + "\n")

print("Parsed:", len(rows))
PYTHON

echo "[STEP] Ranking with real triage scoring..."

python3 - <<PYTHON
import csv

rows = []

with open("$PARSED") as f:
    reader = csv.DictReader(f)
    for r in reader:
        try:
            mag = float(r["mag"])
            obs = float(r["obs"])
            uncert = float(r["uncert"])
            motion = float(r["motion"])

            # REAL TRIAGE LOGIC
            triage = (
                (1 / (obs + 1)) * 50 +     # fewer observations = higher priority
                uncert * 20 +             # uncertainty matters
                motion * 5 +              # motion = trackability / urgency
                (25 - mag)                # brighter = higher priority
            )

            rows.append((triage, r))
        except:
            continue

rows.sort(reverse=True, key=lambda x: x[0])

with open("$RANKED", "w") as out:
    out.write("AMETHYST-SIGINT NEOCP V2 RANKING\n")
    out.write("====================================\n\n")

    for score, r in rows[:20]:
        out.write(
            f"{r['obj']} | triage={score:.3f} | "
            f"mag={r['mag']} obs={r['obs']} "
            f"uncert={r['uncert']} motion={r['motion']}\n"
        )

print("Ranked:", len(rows))
PYTHON

echo "[STEP] Output:"
echo "$OUT"
echo "===================================="
echo "[SUCCESS] V2 TRIAGE COMPLETE"
echo "===================================="
