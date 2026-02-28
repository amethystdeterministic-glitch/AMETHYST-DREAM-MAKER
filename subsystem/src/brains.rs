use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BrainSpec {
    pub name: String,
    pub kind: String,     // e.g. "planner", "language", "coder"
    pub endpoint: String, // e.g. http://127.0.0.1:8081
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BrainOutput {
    pub brain_name: String,
    pub input_hash: String,
    pub output_text: String,
    pub output_hash: String,
}

pub fn hash_text(s: &str) -> String {
    let mut h = Sha256::new();
    h.update(s.as_bytes());
    format!("{:x}", h.finalize())
}

pub fn make_brain_output(brain_name: &str, input: &str, output_text: &str) -> BrainOutput {
    let input_hash = hash_text(input);
    let output_hash = hash_text(output_text);
    BrainOutput {
        brain_name: brain_name.to_string(),
        input_hash,
        output_text: output_text.to_string(),
        output_hash,
    }
}
