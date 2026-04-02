#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 5 — SIGNAL → PILGRIM ROUTING"
echo "===================================="

########################################
# PATCH RUNTIME (SIGNAL HANDLER)
########################################

cat > ~/dqi_v1/src/signal_router.rs << 'EOS'
use std::process::Command;

pub fn route_signal(signal: &str) {

    println!("[ROUTER] received: {}", signal);

    // --- SIMPLE INTENT ROUTING ---
    let engine = if signal.to_lowercase().contains("alzheimer") {
        "alzheimers"
    } else if signal.to_lowercase().contains("cancer") {
        "cancer_research"
    } else if signal.to_lowercase().contains("market") {
        "business"
    } else {
        "creative"
    };

    println!("[ROUTER] engine selected: {}", engine);

    // --- EXECUTE PILGRIM ENGINE ---
    let output = Command::new("pilgrim_cmd")
        .arg("run")
        .arg(engine)
        .output();

    match output {
        Ok(out) => {
            println!("[ROUTER] pilgrim executed");
            println!("{}", String::from_utf8_lossy(&out.stdout));
        },
        Err(e) => {
            println!("[ROUTER ERROR] {}", e);
        }
    }

    println!("[ACTION] COLLAPSE → {}", engine);
}
EOS

########################################
# PATCH MAIN RUNTIME
########################################

cat > ~/dqi_v1/src/main.rs << 'EOS'
mod signal_router;

use std::fs::OpenOptions;
use std::io::{Read};
use std::{thread, time::Duration};

fn main() {
    println!("[RUNTIME] STARTED");
    println!("[RUNTIME] LISTENING");

    let pipe_path = "/data/data/com.termux/files/home/dqi_pipe";

    loop {
        if let Ok(mut file) = OpenOptions::new().read(true).open(pipe_path) {
            let mut buffer = String::new();

            if file.read_to_string(&mut buffer).is_ok() {
                let input = buffer.trim();

                if !input.is_empty() {
                    println!("[SIGNAL RECEIVED]");
                    println!("{}", input);

                    println!("[DQI] routing...");
                    signal_router::route_signal(input);
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
echo "[DONE] SIGNAL → PILGRIM ACTIVE"
echo ""
echo "Test with:"
echo "  dqi_signal \"run alzheimers analysis\""
echo "  dqi_signal \"find market leads\""
echo "  dqi_signal \"creative idea\""
echo "  dqi_log"
echo "===================================="

