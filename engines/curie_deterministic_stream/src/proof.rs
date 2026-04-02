use anyhow::Result;
use chrono::Utc;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs;

use crate::dispatch::DispatchResult;
use crate::window::WindowRecord;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WindowProof {
    pub timestamp_utc: String,
    pub window_id: String,
    pub start_offset: usize,
    pub end_offset: usize,
    pub input_hash: String,
    pub selected: String,
    pub hypotheses: Vec<(String, f64)>,
}

pub fn hash_values(values: &[String]) -> String {
    let mut hasher = Sha256::new();
    for v in values {
        hasher.update(v.as_bytes());
        hasher.update(b"\n");
    }
    format!("{:x}", hasher.finalize())
}

pub fn write_window_proof(proof_dir: &str, window: &WindowRecord, result: &DispatchResult) -> Result<()> {
    let proof = WindowProof {
        timestamp_utc: Utc::now().to_rfc3339(),
        window_id: window.window_id.clone(),
        start_offset: window.start_offset,
        end_offset: window.end_offset,
        input_hash: hash_values(&window.values),
        selected: result.selected.clone(),
        hypotheses: result.hypotheses.iter().map(|h| (h.hypothesis.clone(), h.score)).collect(),
    };

    let path = format!("{}/{}_proof.json", proof_dir, window.window_id);
    fs::write(path, serde_json::to_string_pretty(&proof)?)?;
    Ok(())
}
