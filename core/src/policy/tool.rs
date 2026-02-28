use std::collections::{HashMap, HashSet};
use crate::capability::definition::Capability;

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

pub fn required_capabilities(tool: &str) -> Result<Vec<Capability>, String> {
    let mut map: HashMap<&str, Vec<Capability>> = HashMap::new();

    map.insert(
        "forge_execute",
        vec![
            Capability::ToolExecution,
            Capability::FilesystemWrite,
        ],
    );

    map.insert(
        "export_proof",
        vec![
            Capability::FilesystemRead,
        ],
    );

    match map.get(tool) {
        Some(caps) => Ok(caps.clone()),
        None => Err(format!("No capability contract defined for tool '{}'", tool)),
    }
}
