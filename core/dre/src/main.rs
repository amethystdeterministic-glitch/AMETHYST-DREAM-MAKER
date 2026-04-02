use axum::{routing::post, routing::get, Router};
use std::net::SocketAddr;

mod allowlist;
mod enforce_patch;

async fn enforce(body: String) -> String {
    enforce_patch::handle_enforce(&body)
}

async fn status() -> String {
    let log_path = std::env::var("HOME").unwrap() + "/.amethyst_logs/enforcement.jsonl";

    let last = std::fs::read_to_string(log_path)
        .ok()
        .and_then(|c| c.lines().last().map(|s| s.to_string()))
        .unwrap_or_else(|| "none".into());

    format!(
        r#"{{"status":"OK","dre":"running","last_action":{}}}"#,
        serde_json::to_string(&last).unwrap()
    )
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/enforce", post(enforce))
        .route("/status", get(status));

    let addr = SocketAddr::from(([127, 0, 0, 1], 7878));
    println!("[DRE] listening on http://{}", addr);

    axum::serve(
        tokio::net::TcpListener::bind(addr).await.unwrap(),
        app
    ).await.unwrap();
}
