use serde::{Serialize, Deserialize};

use odin_core::OdinCore;
use crate::{ToolCall, ToolResult, Receipt};
use crate::{syscall_record_brain_output, syscall_submit_and_finalize, syscall_execute_tool_for_intent};
use crate::{BrainOutput};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub ok: bool,
    pub state: String,
    pub value: Option<T>,
    pub error: Option<String>,
}

fn state_string(core: &OdinCore) -> String {
    format!("{:?}", core.state())
}

/// The ONLY mutation-capable surface (and it still respects GREEN-only enforcement).
pub fn submit_intent_and_finalize(core: &mut OdinCore, request: &str) -> ApiResponse<Receipt> {
    if format!("{:?}", core.state()) == "Red" {
        return ApiResponse { ok: false, state: state_string(core), value: None, error: Some("RED mode: mutation blocked".into()) };
    }

    match syscall_submit_and_finalize(core, request) {
        Ok(r) => ApiResponse { ok: true, state: state_string(core), value: Some(r), error: None },
        Err(e) => ApiResponse { ok: false, state: state_string(core), value: None, error: Some(format!("{}", e)) },
    }
}

pub fn record_brain_evidence(core: &mut OdinCore, output: &BrainOutput) -> ApiResponse<()> {
    if format!("{:?}", core.state()) == "Red" {
        return ApiResponse { ok: false, state: state_string(core), value: None, error: Some("RED mode: mutation blocked".into()) };
    }

    match syscall_record_brain_output(core, output) {
        Ok(_) => ApiResponse { ok: true, state: state_string(core), value: Some(()), error: None },
        Err(e) => ApiResponse { ok: false, state: state_string(core), value: None, error: Some(format!("{}", e)) },
    }
}

pub fn execute_tool_for_intent(core: &mut OdinCore, intent_id: &str, call: &ToolCall) -> ApiResponse<ToolResult> {
    if format!("{:?}", core.state()) == "Red" {
        return ApiResponse { ok: false, state: state_string(core), value: None, error: Some("RED mode: mutation blocked".into()) };
    }

    match syscall_execute_tool_for_intent(core, intent_id, call) {
        Ok(r) => ApiResponse { ok: true, state: state_string(core), value: Some(r), error: None },
        Err(e) => ApiResponse { ok: false, state: state_string(core), value: None, error: Some(format!("{}", e)) },
    }
}

/// Read-only: proof export (safe in GREEN or RED).
pub fn export_proof_bundle_json(core: &OdinCore, path: &str, intent_id: Option<&str>) -> ApiResponse<()> {
    match core.export_proof_bundle_json(path, intent_id) {
        Ok(_) => ApiResponse { ok: true, state: state_string(core), value: Some(()), error: None },
        Err(e) => ApiResponse { ok: false, state: state_string(core), value: None, error: Some(e.into()) },
    }
}
