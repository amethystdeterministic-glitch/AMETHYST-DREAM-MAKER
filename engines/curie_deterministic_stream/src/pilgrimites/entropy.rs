use std::collections::HashMap;

pub struct EntropyResult {
    pub entropy_score: f64,
    pub classification: String,
}

pub fn calculate_entropy(window: &Vec<char>) -> EntropyResult {
    let mut freq: HashMap<char, usize> = HashMap::new();

    for c in window {
        *freq.entry(*c).or_insert(0) += 1;
    }

    let len = window.len() as f64;
    let mut entropy = 0.0;

    for count in freq.values() {
        let p = *count as f64 / len;
        entropy -= p * p.log2();
    }

    // 🔥 NEW LOGIC (CRITICAL)
    let classification = if entropy < 1.2 {
        "LOW_ENTROPY_SIMPLE"
    } else if entropy < 2.8 {
        "MID_ENTROPY_STRUCTURED"
    } else {
        "HIGH_ENTROPY_COMPLEX"
    };

    EntropyResult {
        entropy_score: entropy,
        classification: classification.to_string(),
    }
}
