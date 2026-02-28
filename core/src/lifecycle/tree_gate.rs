use crate::policy::{tool, path, port, role};
use crate::policy::role::Role;

pub struct TreeGateInput<'a> {
    pub tool_name: &'a str,
    pub target_path: &'a str,
    pub port: u16,
    pub role: Role,
}

pub fn validate_tree_gate(input: &TreeGateInput) -> Result<(), String> {
    tool::validate_tool(input.tool_name)?;
    path::validate_path(input.target_path)?;
    port::validate_port(input.port)?;
    role::validate_role(&input.role, input.tool_name)?;
    Ok(())
}
