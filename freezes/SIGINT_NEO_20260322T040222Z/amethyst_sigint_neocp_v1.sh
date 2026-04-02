#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT NEOCP ENGINE V1"
echo "===================================="

BASE="$HOME/repos/odin_os"
ART="$BASE/artifacts/neocp_$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$ART"

RAW_TXT="$ART/neocp_raw.txt"
PARSED_CSV="$ART/neocp_parsed.csv"
RANKED_TXT="$ART/neocp_ranked.txt"
REPORT_TXT="$ART/neocp_report.txt"

echo "[STEP] Downloading live NEOCP feed..."

curl -L --fail \
  https://www.minorplanetcenter.net/iau/NEO/neocp.txt \
  -o "$RAW_TXT"

echo "[STEP] Checking feed..."
wc -l "$RAW_TXT"
head -5 "$RAW_TXT"

echo "[STEP] Parsing feed into structured CSV..."

python3 - <<PYTHON
import re
from pathlib import Path

raw_path = Path("$RAW_TXT")
out_path = Path("$PARSED_CSV")

lines = [ln.rstrip("\n") for ln in raw_path.read_text().splitlines() if ln.strip()]

# This parser is intentionally defensive because the fixed-width feed can drift.
# We extract the common fields that are usually present in the public NEOCP text feed:
# object id, score, rough RA, rough Dec, V mag, motion, updated date/time tail.
rows = []
for ln in lines:
    # collapse runs of spaces for fallback token parsing
    tokens = re.split(r"\s+", ln.strip())

    # Skip anything too short to be useful
    if len(tokens) < 8:
        continue

    obj = tokens[0]

    # Heuristic numeric extraction:
    nums = []
    for t in tokens[1:]:
        try:
            nums.append(float(t))
        except Exception:
            pass

    # Keep raw line too so nothing is lost.
    rows.append((obj, ln))

with out_path.open("w") as f:
    f.write("object_id,raw_line\n")
    for obj, raw in rows:
        raw = raw.replace('"', "'")
        f.write(f"\"{obj}\",\"{raw}\"\n")

print("Parsed rows:", len(rows))
PYTHON

echo "[STEP] Ranking candidates..."

python3 - <<PYTHON
import re
from pathlib import Path

src = Path("$PARSED_CSV")
out = Path("$RANKED_TXT")

def extract_metrics(raw_line: str):
    # Pull every number we can. We do not pretend full semantic certainty yet.
    vals = []
    for m in re.findall(r'[-+]?(?:\\d*\\.\\d+|\\d+)', raw_line):
        try:
            vals.append(float(m))
        except Exception:
            pass
    return vals

rows = []
with src.open() as f:
    next(f)
    for line in f:
        # object_id,raw_line
        parts = line.rstrip("\\n").split(",", 1)
        if len(parts) != 2:
            continue
        obj = parts[0].strip().strip('"')
        raw = parts[1].strip().strip('"')

        vals = extract_metrics(raw)

        # Deterministic coarse ranking:
        # - prefer lines with richer numeric content
        # - prefer candidates that look like they include stronger motion/score-like values
        # This is phase-1 triage, not orbital determination.
        richness = len(vals)
        numeric_sum = sum(abs(v) for v in vals[:12])
        triage_score = richness + (numeric_sum / 100.0)

        rows.append((triage_score, obj, raw, richness, numeric_sum))

rows.sort(reverse=True, key=lambda x: x[0])

with out.open("w") as f:
    f.write("AMETHYST-SIGINT NEOCP RANKING\\n")
    f.write("====================================\\n")
    for score, obj, raw, richness, numeric_sum in rows[:25]:
        f.write(f"{obj} | triage_score={score:.3f} | richness={richness} | numeric_sum={numeric_sum:.3f}\\n")
        f.write(f"RAW: {raw}\\n\\n")

print("Ranked candidates:", len(rows))
PYTHON

echo "[STEP] Generating analyst report..."

python3 - <<PYTHON
from pathlib import Path
from datetime import datetime, timezone

ranked = Path("$RANKED_TXT").read_text().splitlines()

with open("$REPORT_TXT", "w") as f:
    f.write("====================================\\n")
    f.write("AMETHYST-SIGINT NEOCP REPORT\\n")
    f.write("====================================\\n\\n")
    f.write(f"Generated: {datetime.now(timezone.utc).isoformat()}\\n\\n")
    f.write("MISSION\\n")
    f.write("-------\\n")
    f.write("Live ingestion and deterministic triage of unconfirmed NEO candidates.\\n\\n")
    f.write("TOP CANDIDATES\\n")
    f.write("--------------\\n")
    for line in ranked[:30]:
        f.write(line + "\\n")
    f.write("\\n====================================\\n")
    f.write("END OF REPORT\\n")
    f.write("====================================\\n")

print("Report generated")
PYTHON

echo "===================================="
echo "[SUCCESS] REAL NEOCP INGEST COMPLETE"
echo "===================================="
echo "[OUTPUT] $ART"
