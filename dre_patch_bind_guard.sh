#!/data/data/com.termux/files/usr/bin/bash
set -e

FILE=~/repos/odin_os/core/dre/src/main.rs
BACKUP=~/repos/odin_os/core/dre/src/main.rs.bak_$(date -u +"%Y%m%dT%H%M%SZ")

cp "$FILE" "$BACKUP"

python - << 'PY'
from pathlib import Path
p = Path.home() / "repos/odin_os/core/dre/src/main.rs"
s = p.read_text()

old = 'let listener = TcpListener::bind("127.0.0.1:7878").unwrap();'
new = '''let listener = match TcpListener::bind("127.0.0.1:7878") {
        Ok(l) => {
            println!("[DRE] listening on http://127.0.0.1:7878");
            l
        }
        Err(e) => {
            eprintln!("[DRE ERROR] Failed to bind 127.0.0.1:7878: {}", e);
            std::process::exit(1);
        }
    };'''

if old not in s:
    raise SystemExit("TARGET LINE NOT FOUND: no patch applied")

s = s.replace(old, new, 1)
p.write_text(s)
print("PATCH APPLIED:", p)
PY

echo "[OK] backup: $BACKUP"
