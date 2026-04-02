#!/data/data/com.termux/files/usr/bin/bash
set -e

FILE=~/repos/odin_os/core/dre/src/main.rs
BACKUP=${FILE}.bak_$(date -u +"%Y%m%dT%H%M%SZ")

cp "$FILE" "$BACKUP"

python - << 'PY'
from pathlib import Path

p = Path.home() / "repos/odin_os/core/dre/src/main.rs"
s = p.read_text()

# Replace the async bind unwrap with a guarded bind
old = 'tokio::net::TcpListener::bind(addr).await.unwrap()'

new = '''{
        use tokio::net::TcpListener;
        use tokio::net::TcpStream;

        if TcpStream::connect(addr).await.is_ok() {
            eprintln!("[DRE] already running on {}", addr);
            std::process::exit(0);
        }

        match TcpListener::bind(addr).await {
            Ok(l) => l,
            Err(e) => {
                eprintln!("[DRE ERROR] bind failed on {}: {}", addr, e);
                std::process::exit(1);
            }
        }
    }'''

if old not in s:
    raise SystemExit("AXUM BIND PATTERN NOT FOUND — aborting")

s = s.replace(old, new, 1)
p.write_text(s)

print("PATCH APPLIED TO AXUM BIND")
PY

echo "[OK] backup saved to $BACKUP"
