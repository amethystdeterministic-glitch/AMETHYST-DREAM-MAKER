pub fn entropy_score(window: &str) -> (f64, String) {
    use std::collections::HashMap;

    let mut freq = HashMap::new();
    let len = window.len() as f64;

    if len == 0.0 {
        return (0.0, "EMPTY".to_string());
    }

    for c in window.chars() {
        *freq.entry(c).or_insert(0) += 1;
    }

    let mut entropy = 0.0;

    for (_char, count) in freq {
        let p = count as f64 / len;
        entropy -= p * p.log2();
    }

    let class = if entropy < 2.5 {
        "LOW_ENTROPY_STRUCTURED"
    } else if entropy < 3.2 {
        "MID_ENTROPY_STRUCTURED"
    } else {
        "HIGH_ENTROPY_COMPLEX"
    };

    (entropy, class.to_string())
}
