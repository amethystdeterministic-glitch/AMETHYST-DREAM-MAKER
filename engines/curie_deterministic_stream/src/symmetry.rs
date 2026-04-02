pub fn symmetry_score(window: &str) -> (u32, String) {
    let chars: Vec<char> = window.chars().collect();
    let len = chars.len();

    if len == 0 {
        return (0, "EMPTY".to_string());
    }

    // --- PERFECT MIRROR ---
    let mut mirror_matches = 0;
    for i in 0..len/2 {
        if chars[i] == chars[len - 1 - i] {
            mirror_matches += 1;
        }
    }

    // --- SUBSTRING REPETITION ---
    let mut repetition_score = 0;
    for size in 2..=len/2 {
        for i in 0..=(len - size * 2) {
            let a: String = chars[i..i+size].iter().collect();
            let b: String = chars[i+size..i+size*2].iter().collect();
            if a == b {
                repetition_score += 1;
            }
        }
    }

    // --- PARTIAL STRUCTURE ---
    let mut partial_matches = 0;
    for i in 0..len-1 {
        if chars[i] == chars[i+1] {
            partial_matches += 1;
        }
    }

    let total_score = mirror_matches + repetition_score + partial_matches;

    let class = if total_score > 5 {
        "HIGH_SYMMETRY"
    } else if total_score > 2 {
        "MID_SYMMETRY"
    } else {
        "LOW_SYMMETRY"
    };

    (total_score as u32, class.to_string())
}
