pub fn joe_tokenize(signal: &str) -> Vec<char> {
    signal.chars().collect()
}

// Simple deterministic rhythm scoring
pub fn joe_score(tokens: &Vec<char>) -> i32 {
    let mut score = 0;

    for i in 1..tokens.len() {
        // repetition detection
        if tokens[i] == tokens[i - 1] {
            score += 2;
        }

        // alphanumeric pattern shift
        if tokens[i].is_alphanumeric() && tokens[i - 1].is_alphanumeric() {
            score += 1;
        }
    }

    // structural bonus for length
    if tokens.len() >= 6 {
        score += 2;
    }

    score
}
