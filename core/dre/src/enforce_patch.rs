use serde_json::Value;
use sha2::{Digest, Sha256};
use std::fs::OpenOptions;
use std::io::Write;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::allowlist;

pub fn handle_enforce(input: &str) -> String {
    let parsed: Value = match serde_json::from_str(input) {
        Ok(v) => v,
        Err(_) => {
            return r#"{"status":"REJECTED","message":"invalid json"}"#.to_string();
        }
    };

    let action = parsed.get("action").and_then(|v| v.as_str()).unwrap_or("");
    let payload = parsed.get("payload").and_then(|v| v.as_str()).unwrap_or("");

    let ts = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();

    let mut record = serde_json::json!({
        "action": action,
        "payload": payload,
        "ts": ts
    });

    if !allowlist::is_allowed(action) {
        record["status"] = Value::String("REJECTED".into());
        record["message"] = Value::String(format!("blocked by allowlist: {}", action));
    } else {
        record["status"] = Value::String("ENFORCED".into());
        record["message"] = Value::String("Action accepted".into());
    }

    let mut hasher = Sha256::new();
    hasher.update(record.to_string());
    let hash = format!("{:x}", hasher.finalize());

    record["proof_hash"] = Value::String(hash.clone());

    let log_path = std::env::var("HOME").unwrap() + "/.amethyst_logs/enforcement.jsonl";

    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(log_path)
        .unwrap();

    writeln!(file, "{}", record).unwrap();

    serde_json::to_string(&record).unwrap()
}
