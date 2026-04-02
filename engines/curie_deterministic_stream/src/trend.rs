pub fn classify_trend(prev_freq: i32, current_freq: i32) -> String {
    if current_freq > prev_freq {
        "RISING".to_string()
    } else if current_freq < prev_freq {
        "FALLING".to_string()
    } else {
        "STABLE".to_string()
    }
}
