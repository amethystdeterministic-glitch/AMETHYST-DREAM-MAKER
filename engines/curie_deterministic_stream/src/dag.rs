pub fn allow_anomaly(entropy: f64, symmetry: i32, window: &str) -> bool {

    let unique: std::collections::HashSet<char> = window.chars().collect();

    // Reject trivial
    if unique.len() <= 2 {
        return false;
    }

    // Reject low entropy
    if entropy < 2.3 {
        return false;
    }

    // Reject high symmetry (too uniform)
    if symmetry > 5 {
        return false;
    }

    // NEW: require diversity + variation
    let has_letters = window.chars().any(|c| c.is_ascii_alphabetic());
    let has_numbers = window.chars().any(|c| c.is_ascii_digit());

    if !(has_letters && has_numbers) {
        return false;
    }

    true
}
