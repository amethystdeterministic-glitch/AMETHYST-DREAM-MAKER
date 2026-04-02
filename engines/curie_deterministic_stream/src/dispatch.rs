use serde::{Deserialize, Serialize};

use crate::window::WindowRecord;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HypothesisScore {
    pub hypothesis: String,
    pub score: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DispatchResult {
    pub window_id: String,
    pub hypotheses: Vec<HypothesisScore>,
    pub selected: String,
    pub rationale: String,
}

fn count_repetition(values: &[String]) -> f64 {
    if values.is_empty() {
        return 0.0;
    }
    let mut repeats = 0usize;
    for i in 1..values.len() {
        if values[i] == values[i - 1] {
            repeats += 1;
        }
    }
    repeats as f64 / values.len() as f64
}

fn count_alternation(values: &[String]) -> f64 {
    if values.len() < 3 {
        return 0.0;
    }
    let mut hits = 0usize;
    for i in 2..values.len() {
        if values[i] == values[i - 2] && values[i] != values[i - 1] {
            hits += 1;
        }
    }
    hits as f64 / values.len() as f64
}

fn count_diversity(values: &[String]) -> f64 {
    use std::collections::HashSet;
    let set: HashSet<_> = values.iter().collect();
    set.len() as f64 / values.len().max(1) as f64
}

pub fn evaluate_window(window: &WindowRecord) -> DispatchResult {
    let repetition = count_repetition(&window.values);
    let alternation = count_alternation(&window.values);
    let diversity = count_diversity(&window.values);

    let hypotheses = vec![
        HypothesisScore {
            hypothesis: "noise".to_string(),
            score: diversity,
        },
        HypothesisScore {
            hypothesis: "repetition_pattern".to_string(),
            score: repetition,
        },
        HypothesisScore {
            hypothesis: "alternating_pattern".to_string(),
            score: alternation,
        },
        HypothesisScore {
            hypothesis: "structured_signal".to_string(),
            score: (repetition * 0.45) + (alternation * 0.45) + ((1.0 - diversity) * 0.10),
        },
    ];

    let mut best = hypotheses[0].clone();
    for h in &hypotheses {
        if h.score > best.score {
            best = h.clone();
        }
    }

    DispatchResult {
        window_id: window.window_id.clone(),
        hypotheses,
        selected: best.hypothesis,
        rationale: "local deterministic branch selection".to_string(),
    }
}
