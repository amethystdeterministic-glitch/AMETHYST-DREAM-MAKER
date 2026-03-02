#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="audit/core/out"
mkdir -p "$OUT"
LOG="$OUT/20_build_release.txt"
: > "$LOG"

echo "[BUILD] cargo clean" | tee -a "$LOG"
cargo clean >>"$LOG" 2>&1

echo "[BUILD] cargo build --release (capturing warnings)" | tee -a "$LOG"
cargo build --release >>"$LOG" 2>&1

echo "[HASH] sha256 of executables in target/release" | tee -a "$LOG"

mapfile -d '' EXEC_FILES < <(find target/release -maxdepth 1 -type f -executable -print0)

if [[ ${#EXEC_FILES[@]} -eq 0 ]]; then
  echo "[FAIL] No executables found in target/release" | tee -a "$LOG"
  exit 1
fi

: > "$OUT/20_release_execs.sha256"

for f in "${EXEC_FILES[@]}"; do
  sha256sum "$f" >> "$OUT/20_release_execs.sha256"
done

echo "[OK] Wrote $OUT/20_release_execs.sha256" | tee -a "$LOG"
