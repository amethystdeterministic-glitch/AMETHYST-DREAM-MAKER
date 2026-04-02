pub fn dominance_proximity(runs: i32) -> String {
    match runs {
        0..=3 => "EARLY".to_string(),
        4..=7 => "EMERGING".to_string(),
        8..=10 => "NEAR_DOMINANT".to_string(),
        _ => "DOMINANT".to_string(),
    }
}
