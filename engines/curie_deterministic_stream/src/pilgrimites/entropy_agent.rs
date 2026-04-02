use crate::entropy::entropy_score;

pub fn evaluate(window: &str) -> (String, i32) {
    let (entropy, class) = entropy_score(window);

    if class.contains("STRUCTURED") {
        ("STRUCTURED_SIGNAL".to_string(), 5)
    } else {
        ("NOISE".to_string(), 1)
    }
}
