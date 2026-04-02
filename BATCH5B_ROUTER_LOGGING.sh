#!/data/data/com.termux/files/usr/bin/bash

echo "===================================="
echo "BATCH 5B — ROUTER LOGGING + VISIBILITY"
echo "===================================="

########################################
# PATCH ROUTER WITH LOGGING
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

    let header = format!("[ROUTER] received: {}", signal);
    println!("{}", header);
    log_line(&header);

    // --- ROUTING ---
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

    // --- EXECUTE PILGRIM ---
    let output = Command::new("pilgrim_cmd")
        .arg("run")
        .arg(engine)
        .output();

    match output {
        Ok(out) => {
            let stdout = String::from_utf8_lossy(&out.stdout);

            println!("[PILGRIM OUTPUT]");
            println!("{}", stdout);

            log_line("[PILGRIM OUTPUT]");
            log_line(&stdout);
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
# ADD LOG VIEW COMMAND
########################################

cat > ~/bin/dqi_log << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash
tail -n 50 -f /data/data/com.termux/files/home/dqi_runtime.log
EOS

chmod +x ~/bin/dqi_log

echo ""
echo "[DONE] FULL VISIBILITY ACTIVE"
echo ""
echo "Now run:"
echo "  dqi_signal \"run alzheimers analysis\""
echo "  dqi_log"
echo "===================================="

