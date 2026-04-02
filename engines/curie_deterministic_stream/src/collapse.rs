use crate::svx;
use crate::temporal_memory::TemporalMemoryState;

pub struct CollapseResult {
    pub selected: String,
    pub structured_score: i32,
    pub anomaly_score: i32,
    pub noise_score: i32,
    pub rationale: String,
}

pub fn dqi_collapse(
    decisions: &Vec<(String, i32)>,
    memory: &TemporalMemoryState
) -> CollapseResult {
    let mut structured_score = 0;
    let mut anomaly_score = 0;
    let mut noise_score = 0;

    for (decision, score) in decisions {
        match decision.as_str() {
            "STRUCTURED_SIGNAL" => structured_score += score,
            "COHERENT_ANOMALY" => anomaly_score += score,
            _ => noise_score += score,
        }
    }

    let svx_result = svx::evaluate(decisions);

    anomaly_score += svx_result.score;
    anomaly_score += memory.anomaly_boost();
    structured_score += memory.structured_boost();
    noise_score -= memory.noise_penalty();

    let (selected, rationale) = if anomaly_score > structured_score && anomaly_score > noise_score {
        (
            "COHERENT_ANOMALY".to_string(),
            format!(
                "Anomaly dominated with SVX boost ({}) and temporal memory influence",
                svx_result.class
            ),
        )
    } else if structured_score > noise_score {
        (
            "STRUCTURED_SIGNAL".to_string(),
            format!(
                "Structured signal selected under {} with temporal memory influence",
                svx_result.class
            ),
        )
    } else {
        (
            "NOISE".to_string(),
            format!(
                "Noise dominated under {} after temporal memory influence",
                svx_result.class
            ),
        )
    };

    CollapseResult {
        selected,
        structured_score,
        anomaly_score,
        noise_score,
        rationale,
    }
}
