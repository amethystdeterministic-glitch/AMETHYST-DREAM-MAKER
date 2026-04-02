pub fn classify_lifecycle(runs: i32) -> String {
    if runs < 3 {
        "EMERGING".to_string()
    } else if runs <= 10 {
        "ACTIVE".to_string()
    } else {
        "DOMINANT".to_string()
    }
}
