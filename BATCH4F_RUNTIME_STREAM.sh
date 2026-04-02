#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4F — TRUE STREAM CONSUMER"
echo "===================================="

########################################
# PATCH RUNTIME (BLOCKING STREAM READ)
########################################

cat > ~/dqi_v1/src/main.rs << 'EOS'
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    println!("[RUNTIME] START (STREAM MODE)");

    let pipe_path = "/data/data/com.termux/files/home/.dqi_pipe";

    // 🔥 Open ONCE (this blocks properly)
    let file = File::open(pipe_path).expect("Failed to open pipe");
    let reader = BufReader::new(file);

    println!("[RUNTIME] listening on pipe...");

    for line in reader.lines() {
        if let Ok(signal) = line {
            if !signal.trim().is_empty() {
                println!("===============================");
                println!("[SIGNAL RECEIVED]");
                println!("{}", signal);
                println!("[DQI] processing...");
                println!("[ACTION] COLLAPSE");
            }
        }
    }
}
EOS

########################################
# BUILD + RESTART
########################################

echo "[BUILD] Recompiling runtime..."
cd ~/dqi_v1
cargo build

echo "[RESTART] Applying runtime..."
dqi_stop 2>/dev/null
sleep 1
dqi_start

echo ""
echo "[DONE] STREAM CONSUMER ACTIVE"
echo ""
echo "Now just run:"
echo "  dqi_signal \"test\""
echo ""
echo "No second terminal. No polling."
echo "===================================="
