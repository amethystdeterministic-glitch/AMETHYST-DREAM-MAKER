#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"
OUT="audit/core/out"
mkdir -p "$OUT"

scan_dir() {
  local d="$1"
  if [ -d "$d" ]; then
    echo "[SCAN] TODO/FIXME in $d" >> "$OUT/30_todo_scan.txt"
    grep -RIn --exclude-dir target --exclude-dir .git -E "TODO|FIXME" "$d" >> "$OUT/30_todo_scan.txt" 2>/dev/null || echo "NONE" >> "$OUT/30_todo_scan.txt"
    echo "" >> "$OUT/30_todo_scan.txt"
  else
    echo "[SCAN] $d NOT_FOUND" >> "$OUT/30_todo_scan.txt"
  fi
}

: > "$OUT/30_todo_scan.txt"
scan_dir "core"
scan_dir "src"
scan_dir "."
