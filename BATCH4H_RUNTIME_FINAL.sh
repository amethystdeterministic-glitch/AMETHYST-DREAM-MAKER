#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 4H — FINAL RUNTIME FIX"
echo "===================================="

PIPE="/data/data/com.termux/files/home/.dqi_pipe"
LOG=~/repos/odin_os/artifacts/runtime/dqi_runtime.log

mkdir -p ~/repos/odin_os/artifacts/runtime

########################################
# ENSURE PIPE EXISTS
########################################
rm -f "$PIPE"
mkfifo "$PIPE"

########################################
# PATCH RUNTIME (ROBUST READ + LOGGING)
########################################
cat > ~/dqi_v1/src/main.rs << 'EOS'
use std::fs::{File, OpenOptions};
use std::io::{BufRead, BufReader, Write};

fn log(msg: &str) {
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open("/data/data/com.termux/files/home/repos/odin_os/artifacts/runtime/dqi_runtime.log")
        .unwrap();

    writeln!(file, "{}", msg).unwrap();
}

fn main() {
    let pipe_path = "/data/data/com.termux/files/home/.dqi_pipe";

    log("[RUNTIME] STARTED");

    // 🔥 Open pipe in read+write mode (prevents blocking issues)
    let file = OpenOptions::new()
        .read(true)
        .write(true)
        .open(pipe_path)
        .expect("pipe open failed");

    let reader = BufReader::new(file);

    log("[RUNTIME] LISTENING");

    for line in reader.lines() {
        if let Ok(signal) = line {
            if !signal.trim().is_empty() {
                log("===============================");
                log("[SIGNAL RECEIVED]");
                log(&signal);
                log("[DQI] processing...");
                log("[ACTION] COLLAPSE");
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

# Start runtime with log redirection
nohup ~/dqi_v1/target/debug/dqi_v1 > /dev/null 2>&1 &

echo ""
echo "[DONE] FINAL RUNTIME ACTIVE"
echo ""
echo "Test with:"
echo "  dqi_signal \"final test\""
echo "  dqi_log"
echo "===================================="
