use axum::{
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

use odin_core::OdinCore;
use odin_subsystem::{api::record_brain_evidence, call_language_brain, make_brain_output};

const PILGRIM_PORT: u16 = 1898;
const MODEL_BASE: &str = "http://127.0.0.1:2026";

#[derive(Deserialize)]
struct QueryRequest {
    input: String,
}

#[derive(Serialize)]
struct QueryResponse {
    ok: bool,
    status: String,
    pilgrim: Option<String>,
    error: Option<String>,
}

#[derive(Serialize)]
struct StatusResponse {
    ok: bool,
    pilgrim: String,
    gateway: String,
    model: String,
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/pilgrim/status", get(status))
        .route("/pilgrim/query", post(query));

    let addr = SocketAddr::from(([127, 0, 0, 1], PILGRIM_PORT));
    println!("Pilgrim AI listening on http://{}", addr);

    axum::serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app)
        .await
        .unwrap();
}

async fn root() -> &'static str {
    "Pilgrim AI v1 — Governed Advisory Gateway"
}

async fn status() -> Json<StatusResponse> {
    let model_ok = model_health().await;
    Json(StatusResponse {
        ok: true,
        pilgrim: "Pilgrim AI v1".into(),
        gateway: format!("127.0.0.1:{}", PILGRIM_PORT),
        model: if model_ok { format!("OK ({})", MODEL_BASE) } else { format!("DOWN ({})", MODEL_BASE) },
    })
}

async fn query(Json(payload): Json<QueryRequest>) -> Json<QueryResponse> {
    let input = payload.input.trim().to_string();
    if input.is_empty() {
        return Json(QueryResponse {
            ok: false,
            status: "rejected".into(),
            pilgrim: None,
            error: Some("empty_input".into()),
        });
    }

    // If model is down, fail fast with a clean error.
    if !model_health().await {
        return Json(QueryResponse {
            ok: false,
            status: "model_unreachable".into(),
            pilgrim: None,
            error: Some("model_unreachable".into()),
        });
    }

    // Advisory-only core boot.
    let mut core = OdinCore::boot_ephemeral();

    // Call advisory brain (never panic).
    let brain_text = match call_language_brain(&input).await {
        Ok(t) => t,
        Err(e) => {
            return Json(QueryResponse {
                ok: false,
                status: "brain_call_failed".into(),
                pilgrim: None,
                error: Some(e),
            })
        }
    };

    // Evidence creation (always succeeds).
    let brain_output = make_brain_output("pilgrim_runtime", &input, &brain_text);

    // Recording evidence is best-effort (non-fatal).
    let _ = record_brain_evidence(&mut core, &brain_output);

    Json(QueryResponse {
        ok: true,
        status: "advisory_ok".into(),
        pilgrim: Some(brain_text),
        error: None,
    })
}

async fn model_health() -> bool {
    // Lightweight probe; no reqwest needed.
    // We only need to know if port responds.
    tokio::time::timeout(std::time::Duration::from_millis(500), async {
        match tokio::net::TcpStream::connect(("127.0.0.1", 2026)).await {
            Ok(_) => true,
            Err(_) => false,
        }
    })
    .await
    .unwrap_or(false)
}
