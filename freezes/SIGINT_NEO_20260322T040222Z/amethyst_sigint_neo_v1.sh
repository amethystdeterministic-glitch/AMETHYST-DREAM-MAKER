#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AMETHYST-SIGINT NEO DETECTOR V1"
echo "===================================="

BASE="$HOME/repos/odin_os"
ART="$BASE/artifacts/neo_$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$ART"

RAW="$ART/observations.csv"
ANOM="$ART/anomalies.txt"
TRACK="$ART/tracks.txt"
REPORT="$ART/report.txt"

echo "[STEP] Generating synthetic observation frames..."

python3 - <<PYTHON
import random

rows = []

# 30 frames
for t in range(30):
    # static background stars
    for _ in range(200):
        x = round(random.uniform(0,100), 3)
        y = round(random.uniform(0,100), 3)
        brightness = round(random.uniform(0.5,1.5), 3)
        rows.append((t, x, y, brightness, "background"))

    # moving bright candidate
    x = round(20 + t*1.8, 3)
    y = round(40 + t*0.6, 3)
    brightness = 4.5
    rows.append((t, x, y, brightness, "candidate"))

with open("$RAW", "w") as f:
    f.write("frame,x,y,brightness,label\n")
    for r in rows:
        f.write(f"{r[0]},{r[1]},{r[2]},{r[3]},{r[4]}\n")

print("Observation dataset created:", len(rows))
PYTHON

echo "[STEP] Detecting anomalous points..."

python3 - <<PYTHON
with open("$RAW") as f:
    next(f)
    rows = [line.strip().split(",") for line in f]

hits = []
for frame, x, y, brightness, label in rows:
    b = float(brightness)
    if b > 3.0:
        hits.append((int(frame), float(x), float(y), b))

with open("$ANOM", "w") as f:
    for h in hits:
        f.write(f"{h[0]},{h[1]},{h[2]},{h[3]}\n")

print("Anomalies detected:", len(hits))
PYTHON

echo "[STEP] Building motion track..."

python3 - <<PYTHON
with open("$ANOM") as f:
    pts = [line.strip().split(",") for line in f]

pts = [(int(t), float(x), float(y), float(b)) for t,x,y,b in pts]
pts.sort(key=lambda p: p[0])

with open("$TRACK", "w") as f:
    f.write("frame_from,frame_to,dx,dy\n")
    for i in range(1, len(pts)):
        t0, x0, y0, _ = pts[i-1]
        t1, x1, y1, _ = pts[i]
        dx = round(x1 - x0, 3)
        dy = round(y1 - y0, 3)
        f.write(f"{t0},{t1},{dx},{dy}\n")

print("Track generated:", max(0, len(pts)-1), "segments")
PYTHON

echo "[STEP] Generating report..."

python3 - <<PYTHON
from statistics import mean
from datetime import datetime, timezone

timestamp = datetime.now(timezone.utc).isoformat()

with open("$ANOM") as f:
    anomalies = [line.strip() for line in f if line.strip()]

with open("$TRACK") as f:
    next(f)
    tracks = [line.strip().split(",") for line in f if line.strip()]

dxs = [float(r[2]) for r in tracks] if tracks else [0.0]
dys = [float(r[3]) for r in tracks] if tracks else [0.0]

avg_dx = mean(dxs)
avg_dy = mean(dys)
motion_score = abs(avg_dx) + abs(avg_dy)

assessment = "LOW CONFIDENCE SIGNAL"
if len(anomalies) >= 5 and motion_score > 1.0:
    assessment = "POTENTIAL MOVING OBJECT DETECTED"

with open("$REPORT", "w") as f:
    f.write("====================================\n")
    f.write("AMETHYST-SIGINT NEO REPORT\n")
    f.write("====================================\n\n")
    f.write(f"Generated: {timestamp}\n")
    f.write(f"Anomalous detections: {len(anomalies)}\n")
    f.write(f"Average motion: dx={avg_dx:.3f}, dy={avg_dy:.3f}\n")
    f.write(f"Motion score: {motion_score:.3f}\n")
    f.write(f"Assessment: {assessment}\n\n")

    f.write("TOP ANOMALOUS POINTS\n")
    f.write("--------------------\n")
    for line in anomalies[:10]:
        f.write(line + "\n")

    f.write("\nTRACK SEGMENTS\n")
    f.write("--------------\n")
    for row in tracks[:10]:
        f.write(",".join(row) + "\n")

    f.write("\n====================================\n")
    f.write("END OF REPORT\n")
    f.write("====================================\n")

print("Report generated")
PYTHON

echo "===================================="
echo "[SUCCESS] NEO DETECTION COMPLETE"
echo "===================================="
echo "[OUTPUT] $ART"
