use std::collections::HashMap;

use crate::brains::BrainSpec;

#[derive(Default)]
pub struct BrainRegistry {
    brains: HashMap<String, BrainSpec>,
}

impl BrainRegistry {
    pub fn new() -> Self {
        Self { brains: HashMap::new() }
    }

    pub fn register(&mut self, spec: BrainSpec) {
        self.brains.insert(spec.name.clone(), spec);
    }

    pub fn get(&self, name: &str) -> Option<&BrainSpec> {
        self.brains.get(name)
    }

    pub fn list(&self) -> Vec<&BrainSpec> {
        self.brains.values().collect()
    }
}

use serde_json::json;

pub async fn call_language_brain(input: &str) -> Result<String, String> {
    let client = reqwest::Client::new();

    let payload = json!({
        "model": "qwen",
        "messages": [
            { "role": "user", "content": input }
        ],
        "temperature": 0.2
    });

    let resp = client
        .post("http://127.0.0.1:2026/v1/chat/completions")
        .json(&payload)
        .send()
        .await
        .map_err(|e| e.to_string())?;

    let json: serde_json::Value = resp.json().await.map_err(|e| e.to_string())?;

    let content = json["choices"][0]["message"]["content"]
        .as_str()
        .ok_or("Invalid model response")?;

    Ok(content.to_string())
}
