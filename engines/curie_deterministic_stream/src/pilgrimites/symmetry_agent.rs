use crate::symmetry::symmetry_score;

pub fn evaluate(window: &str) -> (String, i32) {
    let (score, _class) = symmetry_score(window);

    if score > 0 {
        ("PATTERN".to_string(), 3)
    } else {
        ("NOISE".to_string(), 1)
    }
}
