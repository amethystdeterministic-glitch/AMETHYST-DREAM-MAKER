#[derive(Debug, Clone, Copy)]
pub enum MutationType {
    Soft,
    Nasal,
    Aspirate,
    None,
}

pub fn detect_trigger(prev: &str) -> MutationType {
    match prev {
        "dy" | "ei" | "i" => MutationType::Soft,
        "fy" | "yn" => MutationType::Nasal,
        "a" => MutationType::Aspirate,
        _ => MutationType::None,
    }
}

pub fn mutate_initial(token: &str, m: MutationType) -> String {
    if token.is_empty() {
        return token.to_string();
    }

    let mut chars = token.chars();
    let first = chars.next().unwrap();
    let rest: String = chars.collect();

    match m {
        MutationType::Soft => match first {
            'p' => format!("b{}", rest),
            't' => format!("d{}", rest),
            'c' => format!("g{}", rest),
            'P' => format!("B{}", rest),
            'T' => format!("D{}", rest),
            'C' => format!("G{}", rest),
            _ => token.to_string(),
        },
        MutationType::Nasal => match first {
            'b' => format!("m{}", rest),
            'd' => format!("n{}", rest),
            'g' => format!("ng{}", rest),
            'B' => format!("M{}", rest),
            'D' => format!("N{}", rest),
            'G' => format!("Ng{}", rest),
            _ => token.to_string(),
        },
        MutationType::Aspirate => match first {
            'p' => format!("ph{}", rest),
            't' => format!("th{}", rest),
            'c' => format!("ch{}", rest),
            'P' => format!("Ph{}", rest),
            'T' => format!("Th{}", rest),
            'C' => format!("Ch{}", rest),
            _ => token.to_string(),
        },
        MutationType::None => token.to_string(),
    }
}

pub fn apply_mutation_sequence(input: &str) -> String {
    let tokens: Vec<&str> = input.split_whitespace().collect();
    if tokens.is_empty() {
        return input.to_string();
    }

    let mut result: Vec<String> = Vec::new();
    let mut i = 0;

    while i < tokens.len() {
        let current = tokens[i];

        if i + 1 < tokens.len() {
            let mutation = detect_trigger(current);
            if !matches!(mutation, MutationType::None) {
                result.push(current.to_string());
                let mutated = mutate_initial(tokens[i + 1], mutation);
                result.push(mutated);
                i += 2;
                continue;
            }
        }

        result.push(current.to_string());
        i += 1;
    }

    result.join(" ")
}
