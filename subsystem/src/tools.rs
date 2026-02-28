use serde::{Deserialize, Serialize};

use crate::brains::{hash_text};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToolCall {
    pub tool_name: String,
    pub args: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ToolResult {
    pub output_text: String,
    pub output_hash: String,
}

/// Deterministic simulated tool executor.
/// No OS calls. No network. Pure mapping.
pub fn execute_tool_simulated(call: &ToolCall) -> ToolResult {
    // Stable output so the same call gives the same result.
    // Later we will bind real tools behind a deterministic runner.
    let output_text = format!("SIMULATED:{}:{}", call.tool_name, call.args);
    let output_hash = hash_text(&output_text);
    ToolResult { output_text, output_hash }
}
