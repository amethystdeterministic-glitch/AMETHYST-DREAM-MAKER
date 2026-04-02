pub struct SVXResult {
    pub score: i32,
    pub class: String,
}

pub fn evaluate(decisions: &Vec<(String, i32)>) -> SVXResult {
    let mut anomaly_count = 0;
    let mut structured_count = 0;

    for (d, _) in decisions {
        match d.as_str() {
            "COHERENT_ANOMALY" => anomaly_count += 1,
            "STRUCTURED_SIGNAL" => structured_count += 1,
            _ => {}
        }
    }

    let score = anomaly_count * 2 + structured_count;

    let class = if anomaly_count >= 2 {
        "HIGH_RELATIONAL_COHERENCE"
    } else if structured_count > 0 {
        "MEDIUM_RELATIONAL_COHERENCE"
    } else {
        "LOW_RELATIONAL_COHERENCE"
    };

    SVXResult {
        score,
        class: class.to_string(),
    }
}
