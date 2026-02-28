use serde::{Serialize, Deserialize};
use crate::state::CoreState;
use crate::ledger::LedgerEntry;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoreSnapshot {
    pub state: CoreState,
    pub chain_valid: bool,
    pub ledger_len: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntentProofSlice {
    pub intent_id: String,
    pub entries: Vec<LedgerEntry>,
}

impl IntentProofSlice {
    pub fn new(intent_id: String, entries: Vec<LedgerEntry>) -> Self {
        Self { intent_id, entries }
    }
}
