use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FeedbackRecord {
    pub windows_processed: usize,
    pub structured_ratio: f64,
    pub pattern_ratio: f64,
    pub noise_ratio: f64,
    pub recommendation: String,
}

pub fn build_feedback(
    windows_processed: usize,
    structured_hits: usize,
    pattern_hits: usize,
    noise_hits: usize,
) -> FeedbackRecord {
    let total = windows_processed.max(1) as f64;

    let structured_ratio = structured_hits as f64 / total;
    let pattern_ratio = pattern_hits as f64 / total;
    let noise_ratio = noise_hits as f64 / total;

    let recommendation = if structured_ratio >= 0.50 {
        "increase structured-priority weighting".to_string()
    } else if noise_ratio >= 0.50 {
        "increase anomaly discrimination".to_string()
    } else {
        "maintain current thresholds".to_string()
    };

    FeedbackRecord {
        windows_processed,
        structured_ratio,
        pattern_ratio,
        noise_ratio,
        recommendation,
    }
}

pub fn write_feedback(path: &str, feedback: &FeedbackRecord) {
    let json = serde_json::to_string_pretty(feedback).unwrap();
    fs::write(path, json).unwrap();
}
