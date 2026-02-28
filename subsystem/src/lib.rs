use odin_core::OdinCore;
use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum SubsystemError {
    #[error("normalization failed")]
    NormalizationFailed,
    #[error("core rejected intent: {0}")]
    CoreRejected(&'static str),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Receipt {
    pub request: String,
    pub intent_id: String,
    pub finalized: bool,
}

/// Subsystem normalization: make the external request safe and structured.
/// For now: trim + enforce non-empty.
/// Later: schema, scopes, allowlists, routing, etc.
pub fn normalize_request(input: &str) -> Result<String, SubsystemError> {
    let s = input.trim();
    if s.is_empty() {
        return Err(SubsystemError::NormalizationFailed);
    }
    Ok(s.to_string())
}

/// Canonical syscall-style boundary:
/// - normalize external request
/// - submit intent to Core
/// - TreeGate PASS (placeholder policy)
/// - finalize (single-shot enforced by Core)
pub fn syscall_submit_and_finalize(
    core: &mut OdinCore,
    external_request: &str,
) -> Result<Receipt, SubsystemError> {
    let req = normalize_request(external_request)?;

    let intent = core
        .submit_intent(req.clone())
        .map_err(SubsystemError::CoreRejected)?;

    core.tree_gate_pass(&intent)
        .map_err(SubsystemError::CoreRejected)?;

    core.finalize(&intent)
        .map_err(SubsystemError::CoreRejected)?;

    Ok(Receipt {
        request: req,
        intent_id: intent.intent_id,
        finalized: true,
    })
}
