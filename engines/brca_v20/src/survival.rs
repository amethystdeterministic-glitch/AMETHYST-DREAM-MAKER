use crate::data::model::PatientRecord;

pub struct SurvivalSummary {
    pub low_group_avg_score: f64,
    pub high_group_avg_score: f64,
    pub low_group_avg_survival: f64,
    pub high_group_avg_survival: f64,
    pub low_group_events: u64,
    pub high_group_events: u64,
    pub low_group_time_sum: f64,
    pub high_group_time_sum: f64,
    pub hazard_ratio: Option<f64>,
    pub signal: String,
}

pub fn run_survival(records: &[PatientRecord]) -> SurvivalSummary {
    let mut scored: Vec<(f64, &PatientRecord)> =
        records.iter().map(|r| (r.score(), r)).collect();

    scored.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

    let mid = scored.len() / 2;
    let low = &scored[..mid];
    let high = &scored[mid..];

    let low_group_avg_score = if low.is_empty() {
        0.0
    } else {
        low.iter().map(|(s, _)| *s).sum::<f64>() / low.len() as f64
    };

    let high_group_avg_score = if high.is_empty() {
        0.0
    } else {
        high.iter().map(|(s, _)| *s).sum::<f64>() / high.len() as f64
    };

    let low_group_time_sum = low.iter().map(|(_, r)| r.survival_time).sum::<f64>();
    let high_group_time_sum = high.iter().map(|(_, r)| r.survival_time).sum::<f64>();

    let low_group_avg_survival = if low.is_empty() {
        0.0
    } else {
        low_group_time_sum / low.len() as f64
    };

    let high_group_avg_survival = if high.is_empty() {
        0.0
    } else {
        high_group_time_sum / high.len() as f64
    };

    let low_group_events = low.iter().map(|(_, r)| r.event as u64).sum::<u64>();
    let high_group_events = high.iter().map(|(_, r)| r.event as u64).sum::<u64>();

    let low_rate = if low_group_time_sum > 0.0 {
        low_group_events as f64 / low_group_time_sum
    } else {
        0.0
    };

    let high_rate = if high_group_time_sum > 0.0 {
        high_group_events as f64 / high_group_time_sum
    } else {
        0.0
    };

    let hazard_ratio = if low_rate > 0.0 {
        Some(high_rate / low_rate)
    } else {
        None
    };

    let signal = match hazard_ratio {
        Some(hr) if hr > 1.0 => "HIGH SCORE WORSE".to_string(),
        Some(hr) if hr < 1.0 => "HIGH SCORE BETTER".to_string(),
        Some(_) => "NO CLEAR SIGNAL".to_string(),
        None => "INSUFFICIENT EVENTS".to_string(),
    };

    SurvivalSummary {
        low_group_avg_score,
        high_group_avg_score,
        low_group_avg_survival,
        high_group_avg_survival,
        low_group_events,
        high_group_events,
        low_group_time_sum,
        high_group_time_sum,
        hazard_ratio,
        signal,
    }
}
