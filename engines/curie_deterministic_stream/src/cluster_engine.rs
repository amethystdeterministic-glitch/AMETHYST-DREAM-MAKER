#[derive(Clone)]
pub struct Cluster {
    pub id: String,
    pub frequency: i32,
    pub total_similarity: f64,
    pub first_seen_index: usize,
    pub last_seen_index: usize,
}

impl Cluster {
    pub fn new(id: String, index: usize) -> Self {
        Cluster {
            id,
            frequency: 1,
            total_similarity: 1.0,
            first_seen_index: index,
            last_seen_index: index,
        }
    }

    pub fn update(&mut self, similarity: f64, index: usize) {
        self.frequency += 1;
        self.total_similarity += similarity;
        self.last_seen_index = index;
    }

    pub fn strength(&self) -> f64 {
        let avg_similarity = self.total_similarity / self.frequency as f64;
        let persistence = (self.last_seen_index - self.first_seen_index) as f64;

        // Base scoring
        let freq_score = (self.frequency as f64).powf(1.5);
        let mut strength = freq_score + (avg_similarity * 10.0) + persistence;

        // 🔥 DOMINANCE MULTIPLIER
        if self.frequency >= 3 && persistence >= 2.0 && avg_similarity > 0.8 {
            strength *= 1.8;
        }

        strength
    }
}

pub fn rank_clusters(clusters: &Vec<Cluster>) -> Vec<Cluster> {
    let mut ranked = clusters.clone();

    ranked.sort_by(|a, b| {
        b.strength()
            .partial_cmp(&a.strength())
            .unwrap()
    });

    ranked
}
