#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT=~/repos/odin_os
OUT=$ROOT/artifacts/audit/dre_bind_trace_$(date -u +"%Y%m%dT%H%M%SZ").txt

mkdir -p "$ROOT/artifacts/audit"

{
  echo "===================================="
  echo "DRE BIND TRACE"
  echo "===================================="
  echo
  echo "[MAIN.RS AROUND LINE 35]"
  if [ -f "$ROOT/core/dre/src/main.rs" ]; then
    nl -ba "$ROOT/core/dre/src/main.rs" | sed -n '1,120p'
  else
    echo "main.rs not found at $ROOT/core/dre/src/main.rs"
  fi
  echo
  echo "[ALL 7878 REFERENCES]"
  grep -RIn "7878" "$ROOT/core/dre" || true
  echo
  echo "[ALL TcpListener::bind REFERENCES]"
  grep -RIn "TcpListener::bind" "$ROOT/core/dre" || true
  echo
  echo "[ALL axum::serve REFERENCES]"
  grep -RIn "axum::serve" "$ROOT/core/dre" || true
  echo
  echo "[ALL tokio::spawn REFERENCES]"
  grep -RIn "tokio::spawn" "$ROOT/core/dre" || true
  echo
  echo "[ALL serve( REFERENCES]"
  grep -RIn "serve(" "$ROOT/core/dre" || true
  echo
  echo "[ALL start REFERENCES]"
  grep -RIn "start" "$ROOT/core/dre/src" || true
} | tee "$OUT"

echo
echo "[OK] trace written to $OUT"
