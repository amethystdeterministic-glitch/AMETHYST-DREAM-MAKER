mod brains;
mod registry;
mod tools;

pub use brains::{BrainSpec, BrainOutput, make_brain_output, hash_text};
pub use registry::BrainRegistry;
pub use tools::{ToolCall, ToolResult, execute_tool_simulated};

use odin_core::OdinCore;
use serde::{Deserialize, Serialize};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum SubsystemError {
    #[error("normalization failed")]
    NormalizationFailed,
    #[error("core rejected: {0}")]
    CoreRejected(&'static str),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Receipt {
    pub request: String,
    pub intent_id: String,
    pub finalized: bool,
}

pub fn normalize_request(input: &str) -> Result<String, SubsystemError> {
    let s = input.trim();
    if s.is_empty() {
        return Err(SubsystemError::NormalizationFailed);
    }
    Ok(s.to_string())
}

/// Advisory brain event: record in Core ledger as evidence.
/// This does not advance lifecycle.
pub fn syscall_record_brain_output(
    core: &mut OdinCore,
    output: &BrainOutput,
) -> Result<(), SubsystemError> {
    core.record_brain_event(
        &output.brain_name,
        &output.input_hash,
        &output.output_hash,
        &output.output_text,
    ).map_err(SubsystemError::CoreRejected)
}

/// Canonical syscall boundary:
/// normalize → submit intent → TreeGate PASS (placeholder) → finalize
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

/// Stage 6 syscall:
/// - requires finalized intent_id
/// - executes simulated tool
/// - records execution receipt in Core ledger (authoritative)
pub fn syscall_execute_tool_for_intent(
    core: &mut OdinCore,
    intent_id: &str,
    call: &ToolCall,
) -> Result<ToolResult, SubsystemError> {
    let result = execute_tool_simulated(call);

    core.record_execution_receipt(
        intent_id,
        &call.tool_name,
        call.args.clone(),
        &result.output_hash,
    ).map_err(SubsystemError::CoreRejected)?;

    Ok(result)
}
