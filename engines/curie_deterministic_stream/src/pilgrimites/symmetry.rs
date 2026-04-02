pub struct SymmetryResult {
    pub symmetry_score: usize,
    pub classification: String,
}

pub fn analyze_symmetry(window: &Vec<char>) -> SymmetryResult {

    let len = window.len();
    let mut symmetry_score = 0;

    // Simple mirror symmetry check
    for i in 0..len/2 {
        if window[i] == window[len - 1 - i] {
            symmetry_score += 1;
        }
    }

    // Classification
    let classification = if symmetry_score >= len / 3 {
        "HIGH_SYMMETRY"
    } else if symmetry_score > 0 {
        "PARTIAL_SYMMETRY"
    } else {
        "NO_SYMMETRY"
    };

    SymmetryResult {
        symmetry_score,
        classification: classification.to_string(),
    }
}
