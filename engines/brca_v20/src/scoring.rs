use crate::data::model::PatientRecord;

pub struct ScoreSummary {
    pub low_group_avg: f64,
    pub high_group_avg: f64,
}

pub fn run_scoring(records: &[PatientRecord]) -> ScoreSummary {
    let mut scored: Vec<(f64, &PatientRecord)> = records
        .iter()
        .map(|r| (r.score(), r))
        .collect();

    scored.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

    let mid = scored.len() / 2;

    let low = &scored[..mid];
    let high = &scored[mid..];

    let low_avg = low.iter().map(|(s, _)| s).sum::<f64>() / low.len() as f64;
    let high_avg = high.iter().map(|(s, _)| s).sum::<f64>() / high.len() as f64;

    ScoreSummary {
        low_group_avg: low_avg,
        high_group_avg: high_avg,
    }
}
