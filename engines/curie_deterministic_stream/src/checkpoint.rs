use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::fs;

use crate::state::GlobalState;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Checkpoint {
    pub line_offset: usize,
    pub next_window_index: usize,
    pub next_window_start_offset: usize,
    pub state: GlobalState,
}

pub fn write_checkpoint(path: &str, checkpoint: &Checkpoint) -> Result<()> {
    let json = serde_json::to_string_pretty(checkpoint)?;
    fs::write(path, json)?;
    Ok(())
}
