pub struct TemporalMemoryState {
    pub anomaly_streak: i32,
    pub structured_streak: i32,
    pub noise_streak: i32,
    pub last_decision: String,
}

impl TemporalMemoryState {
    pub fn new() -> Self {
        Self {
            anomaly_streak: 0,
            structured_streak: 0,
            noise_streak: 0,
            last_decision: "NONE".to_string(),
        }
    }

    pub fn update(&mut self, decision: &str) {
        match decision {
            "COHERENT_ANOMALY" => {
                self.anomaly_streak += 1;
                self.structured_streak = 0;
                self.noise_streak = 0;
            }
            "STRUCTURED_SIGNAL" => {
                self.structured_streak += 1;
                self.anomaly_streak = 0;
                self.noise_streak = 0;
            }
            _ => {
                self.noise_streak += 1;
                self.anomaly_streak = 0;
                self.structured_streak = 0;
            }
        }

        self.last_decision = decision.to_string();
    }

    pub fn anomaly_boost(&self) -> i32 {
        if self.anomaly_streak >= 2 { 3 } else if self.anomaly_streak == 1 { 1 } else { 0 }
    }

    pub fn structured_boost(&self) -> i32 {
        if self.structured_streak >= 2 { 3 } else if self.structured_streak == 1 { 1 } else { 0 }
    }

    pub fn noise_penalty(&self) -> i32 {
        if self.noise_streak >= 2 { 2 } else { 0 }
    }
}
