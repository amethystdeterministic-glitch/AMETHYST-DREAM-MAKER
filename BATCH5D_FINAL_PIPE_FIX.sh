#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 5D — FINAL PIPE FIX"
echo "===================================="

PIPE="/data/data/com.termux/files/home/.dqi_pipe"

########################################
# ENSURE PIPE EXISTS
########################################
rm -f "$PIPE"
mkfifo "$PIPE"

echo "[OK] Pipe unified at:"
echo "$PIPE"

########################################
# PATCH RUNTIME TO USE SAME PIPE
########################################

cat > ~/dqi_v1/src/main.rs << 'EOS'
mod signal_router;

use std::fs::OpenOptions;
use std::io::{BufRead, BufReader};

fn main() {
    let pipe_path = "/data/data/com.termux/files/home/.dqi_pipe";

    println!("[RUNTIME] STARTED");
    println!("[RUNTIME] LISTENING");

    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .open(pipe_path)
        .expect("pipe open failed");

    let reader = BufReader::new(file);

    for line in reader.lines() {
        if let Ok(signal) = line {
            if !signal.trim().is_empty() {
                println!("[SIGNAL RECEIVED]");
                println!("{}", signal);

                println!("[DQI] routing...");
                signal_router::route_signal(&signal);
            }
        }
    }
}
EOS

########################################
# BUILD + RESTART
########################################

echo "[BUILD] Recompiling..."
cd ~/dqi_v1
cargo build

echo "[RESTART]"
dqi_stop 2>/dev/null
sleep 1
dqi_start

echo ""
echo "[DONE] PIPE FULLY UNIFIED"
echo ""
echo "Now test:"
echo "  dqi_signal \"run alzheimers analysis\""
echo "  sleep 1"
echo "  dqi_log"
echo "===================================="

