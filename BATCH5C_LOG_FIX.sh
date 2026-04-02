#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 5C — LOG FILE FIX"
echo "===================================="

LOG_PATH=/data/data/com.termux/files/home/dqi_runtime.log

########################################
# FORCE CREATE LOG FILE
########################################
touch $LOG_PATH
chmod 666 $LOG_PATH

echo "[OK] Log file ensured at:"
echo "$LOG_PATH"

########################################
# PATCH ROUTER (FORCE FIRST WRITE)
########################################

cat > ~/dqi_v1/src/signal_router.rs << 'EOS'
use std::process::Command;
use std::fs::OpenOptions;
use std::io::Write;

fn log_line(msg: &str) {
    let path = "/data/data/com.termux/files/home/dqi_runtime.log";

    if let Ok(mut file) = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)
    {
        let _ = writeln!(file, "{}", msg);
    }
}

pub fn route_signal(signal: &str) {

    log_line("====================================");
    log_line("[NEW SIGNAL]");

    let header = format!("[ROUTER] received: {}", signal);
    println!("{}", header);
    log_line(&header);

    let engine = if signal.to_lowercase().contains("alzheimer") {
        "alzheimers"
    } else if signal.to_lowercase().contains("cancer") {
        "cancer_research"
    } else if signal.to_lowercase().contains("market") {
        "business"
    } else {
        "creative"
    };

    let route_msg = format!("[ROUTER] engine: {}", engine);
    println!("{}", route_msg);
    log_line(&route_msg);

    let output = Command::new("pilgrim_cmd")
        .arg("run")
        .arg(engine)
        .output();

    match output {
        Ok(out) => {
            let stdout = String::from_utf8_lossy(&out.stdout);

            log_line("[PILGRIM OUTPUT]");
            log_line(&stdout);

            println!("[PILGRIM EXECUTED]");
        },
        Err(e) => {
            let err = format!("[ROUTER ERROR] {}", e);
            println!("{}", err);
            log_line(&err);
        }
    }

    let collapse = format!("[ACTION] COLLAPSE → {}", engine);
    println!("{}", collapse);
    log_line(&collapse);
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

########################################
# FIX LOG COMMAND (SAFE)
########################################

cat > ~/bin/dqi_log << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash
LOG="/data/data/com.termux/files/home/dqi_runtime.log"

if [ ! -f "$LOG" ]; then
  echo "[INFO] Creating log file..."
  touch "$LOG"
fi

tail -n 50 -f "$LOG"
EOS

chmod +x ~/bin/dqi_log

echo ""
echo "[DONE] LOG SYSTEM FIXED"
echo ""
echo "Now do:"
echo "  dqi_signal \"run alzheimers analysis\""
echo "  sleep 1"
echo "  dqi_log"
echo "===================================="

