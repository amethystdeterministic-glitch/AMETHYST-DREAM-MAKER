use axum::{routing::{get, post}, Json, Router};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use uuid::Uuid;

use odin_core::OdinCore;
use odin_subsystem::{
    api::{record_brain_evidence, submit_intent_and_finalize},
    call_language_brain,
    make_brain_output,
};

const PILGRIM_PORT: u16 = 1898;
const MODEL_HOST: &str = "127.0.0.1";
const MODEL_PORT: u16 = 2026;

#[derive(Deserialize)]
struct QueryRequest {
    input: String,
}

#[derive(Deserialize)]
struct IntentRequest {
    request: String,
}

#[derive(Serialize)]
struct QueryResponse {
    ok: bool,
    request_id: String,
    status: String,
    pilgrim: Option<String>,
    error: Option<String>,
}

#[derive(Serialize)]
struct IntentResponse {
    ok: bool,
    request_id: String,
    status: String,
    state: String,
    intent_id: Option<String>,
    finalized: Option<bool>,
    error: Option<String>,
}

#[derive(Serialize)]
struct StatusResponse {
    ok: bool,
    pilgrim: String,
    version: String,
    gateway: String,
    runtime: RuntimeStatus,
}

#[derive(Serialize)]
struct RuntimeStatus {
    ok: bool,
    endpoint: String,
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(root))
        .route("/pilgrim/status", get(status))
        .route("/pilgrim/query", post(query))
        .route("/pilgrim/intent", post(intent));

    let addr = SocketAddr::from(([127, 0, 0, 1], PILGRIM_PORT));
    println!("Pilgrim AI listening on http://{}", addr);

    match tokio::net::TcpListener::bind(addr).await {
        Ok(listener) => {
            if let Err(e) = axum::serve(listener, app).await {
                eprintln!("serve_error: {}", e);
            }
        }
        Err(e) => {
            eprintln!("bind_error addr={} err={}", addr, e);
        }
    }
}

async fn root() -> &'static str {
    "Pilgrim AI — Governed Advisory Gateway"
}

async fn status() -> Json<StatusResponse> {
    let runtime_ok = model_health().await;
    Json(StatusResponse {
        ok: true,
        pilgrim: "Pilgrim AI".into(),
        version: env!("CARGO_PKG_VERSION").into(),
        gateway: format!("127.0.0.1:{}", PILGRIM_PORT),
        runtime: RuntimeStatus {
            ok: runtime_ok,
            endpoint: format!("http://{}:{}", MODEL_HOST, MODEL_PORT),
        },
    })
}

/// Advisory-only endpoint (no mutation surface).
async fn query(Json(payload): Json<QueryRequest>) -> Json<QueryResponse> {
    let request_id = Uuid::new_v4().to_string();
    let input = payload.input.trim().to_string();

    if input.is_empty() {
        return Json(QueryResponse {
            ok: false,
            request_id,
            status: "rejected".into(),
            pilgrim: None,
            error: Some("empty_input".into()),
        });
    }

    if !model_health().await {
        return Json(QueryResponse {
            ok: false,
            request_id,
            status: "model_unreachable".into(),
            pilgrim: None,
            error: Some("model_unreachable".into()),
        });
    }

    let mut core = OdinCore::boot_ephemeral();

    let brain_text = match call_language_brain(&input).await {
        Ok(t) => t,
        Err(e) => {
            return Json(QueryResponse {
                ok: false,
                request_id,
                status: "brain_call_failed".into(),
                pilgrim: None,
                error: Some(e),
            })
        }
    };

    let brain_output = make_brain_output("pilgrim_runtime", &input, &brain_text);
    let _ = record_brain_evidence(&mut core, &brain_output);

    eprintln!(
        "pilgrim.query request_id={} status=advisory_ok input_len={} output_len={}",
        request_id,
        input.len(),
        brain_text.len()
    );

    Json(QueryResponse {
        ok: true,
        request_id,
        status: "advisory_ok".into(),
        pilgrim: Some(brain_text),
        error: None,
    })
}

/// Governed mutation surface (ephemeral).
async fn intent(Json(payload): Json<IntentRequest>) -> Json<IntentResponse> {
    let request_id = Uuid::new_v4().to_string();
    let req = payload.request.trim().to_string();

    if req.is_empty() {
        return Json(IntentResponse {
            ok: false,
            request_id,
            status: "rejected".into(),
            state: "Unknown".into(),
            intent_id: None,
            finalized: None,
            error: Some("empty_request".into()),
        });
    }

    let mut core = OdinCore::boot_ephemeral();

    let res = submit_intent_and_finalize(&mut core, &req);

    // Always return state string from the response.
    if !res.ok {
        eprintln!(
            "pilgrim.intent request_id={} status=blocked_or_failed state={} err={}",
            request_id,
            res.state,
            res.error.clone().unwrap_or_else(|| "unknown".into())
        );

        return Json(IntentResponse {
            ok: false,
            request_id,
            status: "blocked_or_failed".into(),
            state: res.state,
            intent_id: None,
            finalized: None,
            error: res.error,
        });
    }

    let receipt = res.value;

    // receipt should exist if ok=true, but we keep it safe.
    match receipt {
        Some(r) => {
            eprintln!(
                "pilgrim.intent request_id={} status=finalized state={} intent_id={}",
                request_id, res.state, r.intent_id
            );

            Json(IntentResponse {
                ok: true,
                request_id,
                status: "finalized".into(),
                state: res.state,
                intent_id: Some(r.intent_id),
                finalized: Some(r.finalized),
                error: None,
            })
        }
        None => Json(IntentResponse {
            ok: false,
            request_id,
            status: "internal_error".into(),
            state: res.state,
            intent_id: None,
            finalized: None,
            error: Some("missing_receipt".into()),
        }),
    }
}

async fn model_health() -> bool {
    tokio::time::timeout(std::time::Duration::from_millis(500), async {
        tokio::net::TcpStream::connect((MODEL_HOST, MODEL_PORT)).await.is_ok()
    })
    .await
    .unwrap_or(false)
}
