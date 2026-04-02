use std::collections::HashMap;
use crate::normalise::normalise_pattern;

pub fn build_signature(window: &str) -> String {
    let normalised = normalise_pattern(window);

    let mut transitions: HashMap<String, i32> = HashMap::new();
    let chars: Vec<char> = normalised.chars().collect();

    for i in 0..chars.len().saturating_sub(1) {
        let pair = format!("{}{}", chars[i], chars[i+1]);
        *transitions.entry(pair).or_insert(0) += 1;
    }

    let mut keys: Vec<String> = transitions.keys().cloned().collect();
    keys.sort();

    keys.join("|")
}
