use serde::{Serialize, Deserialize};
use std::fs;
use std::time::{SystemTime, UNIX_EPOCH};

use crate::query::{CoreSnapshot, IntentProofSlice};
use crate::ledger::LedgerEntry;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProofBundle {
    pub generated_at_unix: u64,
    pub snapshot: CoreSnapshot,
    pub boot_receipts: Vec<LedgerEntry>,
    pub execution_receipts: Vec<LedgerEntry>,
    pub intent_slice: Option<IntentProofSlice>,
}

impl ProofBundle {
    pub fn write_json_file(&self, path: &str) -> Result<(), &'static str> {
        let s = serde_json::to_string_pretty(self).map_err(|_| "Failed to serialize proof bundle")?;
        fs::write(path, s).map_err(|_| "Failed to write proof bundle")?;
        Ok(())
    }

    pub fn now_unix() -> u64 {
        SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs()
    }
}
