use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConstraintPolicy {
    pub min_pattern_score: i32,
    pub min_structured_score: i32,
    pub allow_noise_collapse: bool,
    pub require_nonzero_windows: bool,
}

impl Default for ConstraintPolicy {
    fn default() -> Self {
        Self {
            min_pattern_score: 1,
            min_structured_score: 6,
            allow_noise_collapse: true,
            require_nonzero_windows: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConstraintCheck {
    pub allowed: bool,
    pub reason: String,
}

pub fn validate_local(decision: &str, score: i32, policy: &ConstraintPolicy) -> ConstraintCheck {
    match decision {
        "STRUCTURED_SIGNAL" if score >= policy.min_structured_score => ConstraintCheck {
            allowed: true,
            reason: "structured threshold satisfied".to_string(),
        },
        "PATTERN" if score >= policy.min_pattern_score => ConstraintCheck {
            allowed: true,
            reason: "pattern threshold satisfied".to_string(),
        },
        "NOISE" if policy.allow_noise_collapse => ConstraintCheck {
            allowed: true,
            reason: "noise collapse permitted".to_string(),
        },
        _ => ConstraintCheck {
            allowed: false,
            reason: "constraint threshold failed".to_string(),
        },
    }
}

pub fn validate_global(processed_windows: usize, policy: &ConstraintPolicy) -> ConstraintCheck {
    if policy.require_nonzero_windows && processed_windows == 0 {
        ConstraintCheck {
            allowed: false,
            reason: "no windows processed".to_string(),
        }
    } else {
        ConstraintCheck {
            allowed: true,
            reason: "global constraints satisfied".to_string(),
        }
    }
}

pub fn write_policy(path: &str, policy: &ConstraintPolicy) {
    let json = serde_json::to_string_pretty(policy).unwrap();
    fs::write(path, json).unwrap();
}
