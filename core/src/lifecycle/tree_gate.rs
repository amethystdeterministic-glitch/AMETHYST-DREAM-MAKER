use crate::policy::{tool, path, port, role};
use crate::policy::role::Role;

use crate::capability::context::CapabilityContext;
use crate::capability::profiles::registry_for_role;
use crate::capability::audit::CapabilityAudit;

pub struct TreeGateInput<'a> {
    pub tool_name: &'a str,
    pub target_path: &'a str,
    pub port: u16,
    pub role: Role,
}

pub fn validate_tree_gate(input: &TreeGateInput) -> Result<CapabilityAudit, String> {
    // Policy checks
    tool::validate_tool(input.tool_name)?;
    path::validate_path(input.target_path)?;
    port::validate_port(input.port)?;
    role::validate_role(&input.role, input.tool_name)?;

    // Deterministic capability derivation
    let registry = registry_for_role(&input.role);
    let caps = CapabilityContext::new(registry);

    // Tool-specific capability enforcement
    let required = tool::required_capabilities(input.tool_name)?;
    for cap in required.clone() {
        caps.require(cap)?;
    }

    // Build audit record (deterministic)
    let derived = caps.registry_list();
    let audit = CapabilityAudit {
        role: input.role.clone(),
        tool: input.tool_name.to_string(),
        derived,
        required,
    };

    Ok(audit)
}
