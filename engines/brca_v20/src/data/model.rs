#[derive(Debug, Clone)]
pub struct PatientRecord {
    pub sample_id: String,
    pub genes: Vec<f64>,
    pub survival_time: f64,
    pub event: u8,
}

impl PatientRecord {
    pub fn score(&self) -> f64 {
        self.genes.iter().sum()
    }
}
