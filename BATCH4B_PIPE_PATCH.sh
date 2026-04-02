#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4B — PIPE SIGNAL PATCH"
echo "===================================="

RUST_MAIN=~/dqi_v1/src/main.rs

########################################
# BACKUP FIRST (SAFE)
########################################
cp $RUST_MAIN ${RUST_MAIN}.bak

########################################
# INJECT PIPE LISTENER + HANDLER
########################################
cat > $RUST_MAIN << 'EOS'
use std::fs::OpenOptions;
use std::io::{BufRead, BufReader};
use std::thread;
use std::time::Duration;

fn handle_signal(signal: String) {
    println!("[PILGRIM] INTENT {}", signal);

    // === KEEP YOUR EXISTING BEHAVIOUR HERE ===
    // You can expand later — this just proves flow
    println!("[EXECUTION] Processing...");
}

fn listen_for_signals() {
    let pipe_path = "/data/data/com.termux/files/home/repos/odin_os/runtime/signal.pipe";

    loop {
        if let Ok(file) = OpenOptions::new().read(true).open(pipe_path) {
            let reader = BufReader::new(file);

            for line in reader.lines() {
                if let Ok(signal) = line {
                    println!("===============================");
                    println!("[SIGNAL RECEIVED]");
                    println!("{}", signal);

                    handle_signal(signal);
                }
            }
        }

        thread::sleep(Duration::from_millis(200));
    }
}

fn main() {
    println!("[RUNTIME] START (SIGNAL MODE)");

    std::thread::spawn(|| {
        listen_for_signals();
    });

    loop {
        println!("[RUNTIME] idle...");
        thread::sleep(Duration::from_secs(2));
    }
}
EOS

########################################
# BUILD
########################################
echo "[BUILD] Recompiling runtime..."
cd ~/dqi_v1
cargo build

########################################
# RESTART CLEAN
########################################
echo "[RESTART] Applying new runtime..."
dqi_stop 2>/dev/null

sleep 1

dqi_start

echo ""
echo "[DONE] PIPE SIGNAL SYSTEM ACTIVE"
echo ""
echo "Test with:"
echo "  dqi_signal \"Explore new decision pathways\""
echo "  dqi_log"
echo "===================================="
