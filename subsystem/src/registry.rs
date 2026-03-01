use serde_json::json;
use reqwest::Client;

#[derive(Debug, Clone)]
pub struct BrainRegistry;

impl BrainRegistry {
    pub fn new() -> Self {
        BrainRegistry
    }
}

pub async fn call_language_brain(input: &str) -> Result<String, String> {
    let client = Client::new();

    let system_identity = r#"You are Pilgrim AI.
You are a governed deterministic advisory intelligence.
You provide formal, concise, structured responses.
You do not speculate.
You do not role-play.
You do not simulate conversations.
You do not express emotion.
You answer precisely."#;

    let prompt = format!(
        "{system}\n\n{user}\nPilgrim:",
        system = system_identity,
        user = input
    );

    let payload = json!({
        "prompt": prompt,
        "temperature": 0.2,
        "max_tokens": 300,
        "presence_penalty": 0.4,
        "frequency_penalty": 0.5,
        "stop": ["User:"]
    });

    let resp = client
        .post("http://127.0.0.1:2026/v1/completions")
        .json(&payload)
        .send()
        .await
        .map_err(|e| e.to_string())?;

    let json: serde_json::Value = resp
        .json()
        .await
        .map_err(|e| e.to_string())?;

    let raw = json["choices"][0]["text"]
        .as_str()
        .unwrap_or("")
        .trim()
        .to_string();

    if raw.is_empty() {
        Ok("Request incomplete. Please restate clearly.".into())
    } else if raw.len() > 1000 {
        Ok(raw[..1000].to_string())
    } else {
        Ok(raw)
    }
}
