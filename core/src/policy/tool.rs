use std::collections::HashSet;

pub fn allowed_tools() -> HashSet<&'static str> {
    let mut set = HashSet::new();
    set.insert("forge_execute");
    set.insert("export_proof");
    set
}

pub fn validate_tool(tool: &str) -> Result<(), String> {
    if allowed_tools().contains(tool) {
        Ok(())
    } else {
        Err(format!("Tool '{}' not allowed by policy", tool))
    }
}
