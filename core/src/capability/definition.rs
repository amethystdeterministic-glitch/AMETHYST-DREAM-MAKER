use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Capability {
    FilesystemRead,
    FilesystemWrite,
    NetworkOutbound,
    ProcessSpawn,
    ToolExecution,
}
