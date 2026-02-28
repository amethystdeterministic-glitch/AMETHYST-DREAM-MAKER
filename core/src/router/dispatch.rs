use serde_json::{json, Value};
use reqwest::blocking::Client;

pub fn brain_port(brain: &str) -> u16 {
    match brain {
        "qwen" => 8081,
        "qwen_coder" => 8082,
        _ => 8081,
    }
}

pub fn build_payload(message: &str) -> Value {
    json!({
        "model": "unused",
        "messages": [
            { "role": "user", "content": message }
        ],
        "temperature": 0.2
    })
}

pub fn call_brain(brain: &str, message: &str) -> Result<String, String> {
    let port = brain_port(brain);
    let url = format!("http://127.0.0.1:{}/v1/chat/completions", port);

    let client = Client::new();
    let payload = build_payload(message);

    let response = client
        .post(&url)
        .json(&payload)
        .send()
        .map_err(|e| e.to_string())?;

    let json: Value = response.json().map_err(|e| e.to_string())?;

    let content = json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("No response")
        .to_string();

    Ok(content)
}
