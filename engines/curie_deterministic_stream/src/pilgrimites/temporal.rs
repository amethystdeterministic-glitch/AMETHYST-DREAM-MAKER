pub struct TemporalResult {
    pub trend: String,
}

pub fn analyze_temporal(decisions: &Vec<String>) -> TemporalResult {

    if decisions.is_empty() {
        return TemporalResult {
            trend: "NO_DATA".to_string(),
        };
    }

    let mut structured_count = 0;
    let mut noise_count = 0;

    for d in decisions {
        if d.contains("STRUCTURED_SIGNAL") {
            structured_count += 1;
        } else if d.contains("NOISE") {
            noise_count += 1;
        }
    }

    let trend = if structured_count > noise_count {
        "PERSISTENT_SIGNAL"
    } else if noise_count > structured_count {
        "EPHEMERAL_OR_NOISE"
    } else {
        "UNSTABLE_PATTERN"
    };

    TemporalResult {
        trend: trend.to_string(),
    }
}
