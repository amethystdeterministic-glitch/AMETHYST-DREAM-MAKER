use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Intent {
    pub intent_id: String,
    pub request: String,
    pub intent_hash: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TreeGate {
    pub intent_id: String,
    pub intent_hash: String,
    pub pass: bool,
    pub reason: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Finalize {
    pub intent_id: String,
    pub intent_hash: String,
}

pub fn hash_intent(request: &str) -> String {
    let mut h = Sha256::new();
    h.update(request.as_bytes());
    format!("{:x}", h.finalize())
}

impl Intent {
    pub fn new(request: String) -> Self {
        let intent_id = Uuid::new_v4().to_string();
        let intent_hash = hash_intent(&request);
        Self { intent_id, request, intent_hash }
    }
}

impl TreeGate {
    pub fn pass(intent: &Intent) -> Self {
        Self {
            intent_id: intent.intent_id.clone(),
            intent_hash: intent.intent_hash.clone(),
            pass: true,
            reason: "PASS".to_string(),
        }
    }

    pub fn fail(intent: &Intent, reason: &str) -> Self {
        Self {
            intent_id: intent.intent_id.clone(),
            intent_hash: intent.intent_hash.clone(),
            pass: false,
            reason: reason.to_string(),
        }
    }
}

impl Finalize {
    pub fn new(intent: &Intent) -> Self {
        Self {
            intent_id: intent.intent_id.clone(),
            intent_hash: intent.intent_hash.clone(),
        }
    }
}
