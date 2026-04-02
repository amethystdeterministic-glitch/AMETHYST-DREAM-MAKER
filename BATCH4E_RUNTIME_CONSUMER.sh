#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4E — RUNTIME PIPE CONSUMER"
echo "===================================="

########################################
# PATCH RUNTIME LOOP (AUTO PIPE READ)
########################################

cat > ~/dqi_v1/src/main.rs << 'EOS'
use std::{thread, time::Duration};
use std::fs::OpenOptions;
use std::io::{BufRead, BufReader};

fn main() {
    println!("[RUNTIME] START (SIGNAL MODE)");

    let pipe_path = "/data/data/com.termux/files/home/.dqi_pipe";

    loop {
        // Open pipe (blocking read)
        if let Ok(file) = OpenOptions::new().read(true).open(pipe_path) {
            let reader = BufReader::new(file);

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

        thread::sleep(Duration::from_millis(200));
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
echo "[DONE] AUTO CONSUMER ACTIVE"
echo ""
echo "Now just run:"
echo "  dqi_signal \"test\""
echo ""
echo "NO second terminal needed"
echo "===================================="
