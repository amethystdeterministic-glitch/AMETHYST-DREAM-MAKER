use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use chrono::Utc;

pub fn write_cluster_ledger(cluster_id: &str, frequency: i32, strength: f64) {
    let ledger_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/cluster_ledger.jsonl";
    let state_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/cluster_state.json";
    let temp_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/cluster_state.tmp";

    let mut last_freq = 0;
    let mut last_runs = 0;

    // 🔥 READ ONLY LAST STATE (NOT FULL HISTORY)
    if let Ok(state) = fs::read_to_string(state_path) {
        if let Some(freq_part) = state.split("\"freq\":").nth(1) {
            let val = freq_part.split(',').next().unwrap_or("0");
            last_freq = val.parse::<i32>().unwrap_or(0);
        }

        if let Some(run_part) = state.split("\"runs\":").nth(1) {
            let val = run_part.split(',').next().unwrap_or("0");
            last_runs = val.parse::<i32>().unwrap_or(0);
        }
    }

    let total_freq = last_freq + frequency;
    let total_runs = last_runs + 1;

    let timestamp = Utc::now().to_rfc3339();

    // HISTORY (append-only)
    let history_line = format!(
        "{{\"ts\":\"{}\",\"cluster\":\"{}\",\"freq\":{},\"runs\":{},\"strength\":{}}}\n",
        timestamp,
        cluster_id,
        total_freq,
        total_runs,
        strength
    );

    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(ledger_path)
        .unwrap();

    file.write_all(history_line.as_bytes()).unwrap();

    // 🔥 CANONICAL STATE (atomic)
    let state_json = format!(
        "{{\"cluster\":\"{}\",\"freq\":{},\"runs\":{},\"strength\":{}}}",
        cluster_id,
        total_freq,
        total_runs,
        strength
    );

    fs::write(temp_path, state_json).unwrap();
    fs::rename(temp_path, state_path).unwrap();
}
