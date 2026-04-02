use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeterministicState {
    pub run_id: String,
    pub processed_windows: usize,
    pub last_global_selection: String,
    pub total_score: i32,
    pub structured_hits: usize,
    pub pattern_hits: usize,
    pub noise_hits: usize,
}

impl DeterministicState {
    pub fn new(run_id: &str) -> Self {
        Self {
            run_id: run_id.to_string(),
            processed_windows: 0,
            last_global_selection: "NONE".to_string(),
            total_score: 0,
            structured_hits: 0,
            pattern_hits: 0,
            noise_hits: 0,
        }
    }

    pub fn record_window(&mut self, decision: &str, score: i32) {
        self.processed_windows += 1;
        self.total_score += score;

        match decision {
            "STRUCTURED_SIGNAL" => self.structured_hits += 1,
            "PATTERN" => self.pattern_hits += 1,
            "NOISE" => self.noise_hits += 1,
            _ => {}
        }
    }

    pub fn set_global_selection(&mut self, selection: &str) {
        self.last_global_selection = selection.to_string();
    }
}

pub fn write_state(path: &str, state: &DeterministicState) {
    let json = serde_json::to_string_pretty(state).unwrap();
    fs::write(path, json).unwrap();
}
