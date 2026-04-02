pub fn normalise_pattern(window: &str) -> String {
    let mut mapping = std::collections::HashMap::new();
    let mut next_char = 'A';

    let mut result = String::new();

    for c in window.chars() {
        let entry = mapping.entry(c).or_insert_with(|| {
            let current = next_char;
            next_char = ((next_char as u8) + 1) as char;
            current
        });
        result.push(*entry);
    }

    result
}
