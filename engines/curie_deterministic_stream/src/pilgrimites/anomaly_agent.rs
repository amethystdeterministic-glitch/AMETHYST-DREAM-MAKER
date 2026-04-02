pub fn evaluate(window: &str) -> (String, i32) {
    if window.len() > 0 {
        ("COHERENT_ANOMALY".to_string(), 8)
    } else {
        ("NOISE".to_string(), 0)
    }
}
