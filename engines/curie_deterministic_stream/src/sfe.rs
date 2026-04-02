use std::collections::HashMap;

pub fn grammar_score(window: &str) -> (i32, String) {
    let mut transitions: HashMap<String, i32> = HashMap::new();
    let chars: Vec<char> = window.chars().collect();

    if chars.len() < 2 {
        return (0, "NO_STRUCTURE".to_string());
    }

    for i in 0..chars.len() - 1 {
        let pair = format!("{}{}", chars[i], chars[i+1]);
        *transitions.entry(pair).or_insert(0) += 1;
    }

    let unique_transitions = transitions.len() as i32;
    let repeated_transitions = transitions.values().filter(|&&v| v > 1).count() as i32;

    let score = unique_transitions + (repeated_transitions * 2);

    let class = if score > 6 {
        "HIGH_STRUCTURE"
    } else if score > 3 {
        "MEDIUM_STRUCTURE"
    } else {
        "LOW_STRUCTURE"
    };

    (score, class.to_string())
}
