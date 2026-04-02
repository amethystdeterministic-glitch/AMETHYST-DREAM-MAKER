use anyhow::Result;
use serde::Serialize;
use sha2::{Digest, Sha256};
use std::fs;
use std::io::Write;
use chrono::Utc;

use crate::data::model::PatientRecord;
use crate::survival::SurvivalSummary;
use crate::signature::SignatureContract;

#[derive(Serialize)]
pub struct RunManifest {
    pub run_id: String,
    pub engine: String,
    pub phase: String,
    pub dataset_path: String,
    pub signature_path: String,
    pub signature_id: String,
    pub signature_gene_count: usize,
    pub records_loaded: usize,
    pub timestamp_utc: String,
}

#[derive(Serialize)]
pub struct MetricsReport {
    pub low_group_avg_score: f64,
    pub high_group_avg_score: f64,
    pub low_group_avg_survival: f64,
    pub high_group_avg_survival: f64,
    pub low_group_events: u64,
    pub high_group_events: u64,
    pub low_group_time_sum: f64,
    pub high_group_time_sum: f64,
    pub hazard_ratio: Option<f64>,
    pub signal: String,
}

pub fn dataset_hash(path: &str) -> Result<String> {
    let bytes = fs::read(path)?;
    let mut hasher = Sha256::new();
    hasher.update(bytes);
    let out = hasher.finalize();
    Ok(format!("{:x}", out))
}

pub fn write_outputs(
    root: &str,
    dataset_path: &str,
    signature_path: &str,
    signature: &SignatureContract,
    records: &[PatientRecord],
    summary: &SurvivalSummary,
) -> Result<String> {
    let run_id = format!("BRCA_V20_{}", Utc::now().format("%Y%m%dT%H%M%SZ"));
    let out_dir = format!("{}/{}", root, run_id);
    fs::create_dir_all(&out_dir)?;

    let manifest = RunManifest {
        run_id: run_id.clone(),
        engine: "brca_v20".to_string(),
        phase: "phase13_artifact_mode".to_string(),
        dataset_path: dataset_path.to_string(),
        signature_path: signature_path.to_string(),
        signature_id: signature.signature_id.clone(),
        signature_gene_count: signature.gene_count,
        records_loaded: records.len(),
        timestamp_utc: Utc::now().to_rfc3339(),
    };

    let metrics = MetricsReport {
        low_group_avg_score: summary.low_group_avg_score,
        high_group_avg_score: summary.high_group_avg_score,
        low_group_avg_survival: summary.low_group_avg_survival,
        high_group_avg_survival: summary.high_group_avg_survival,
        low_group_events: summary.low_group_events,
        high_group_events: summary.high_group_events,
        low_group_time_sum: summary.low_group_time_sum,
        high_group_time_sum: summary.high_group_time_sum,
        hazard_ratio: summary.hazard_ratio,
        signal: summary.signal.clone(),
    };

    fs::write(
        format!("{}/run_manifest.json", out_dir),
        serde_json::to_string_pretty(&manifest)?,
    )?;

    fs::write(
        format!("{}/metrics.json", out_dir),
        serde_json::to_string_pretty(&metrics)?,
    )?;

    let ds_hash = dataset_hash(dataset_path)?;
    let sig_hash = dataset_hash(signature_path)?;

    fs::write(format!("{}/dataset.sha256", out_dir), format!("{}\n", ds_hash))?;
    fs::write(format!("{}/signature.sha256", out_dir), format!("{}\n", sig_hash))?;

    let mut csv = fs::File::create(format!("{}/score_preview.csv", out_dir))?;
    writeln!(csv, "sample_id,score,survival_time,event")?;
    for rec in records.iter().take(25) {
        writeln!(
            csv,
            "{},{},{},{}",
            rec.sample_id,
            rec.score(),
            rec.survival_time,
            rec.event
        )?;
    }

    Ok(out_dir)
}
