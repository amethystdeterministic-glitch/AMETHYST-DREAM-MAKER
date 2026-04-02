use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct ClusterScore {
    pub freq: i32,
    pub strength: f64,
}

pub fn compute_score(freq: i32, anomaly_score: i32) -> f64 {
    (freq as f64 * 2.0) + (anomaly_score as f64 * 1.5)
}

pub fn rank_clusters(clusters: &HashMap<String, ClusterScore>) -> Vec<(String, ClusterScore)> {
    let mut ranked: Vec<(String, ClusterScore)> =
        clusters.iter().map(|(k, v)| (k.clone(), v.clone())).collect();

    ranked.sort_by(|a, b| {
        b.1.strength.partial_cmp(&a.1.strength).unwrap()
    });

    ranked
}
