use serde::Serialize;
use std::fs;

#[derive(Serialize)]
pub struct ContractReport {
    pub ok: bool,
    pub odin_core_version: &'static str,
    pub authority_key_found: bool,
    pub authority_key_path: Option<String>,
    pub ledger_found: bool,
    pub ledger_path: Option<String>,
    pub notes: Vec<String>,
}

fn first_existing_path(candidates: &[&str]) -> Option<String> {
    for p in candidates {
        if fs::metadata(p).is_ok() {
            return Some((*p).to_string());
        }
    }
    None
}

pub fn verify_report() -> ContractReport {
    // We keep this intentionally conservative and deterministic:
    // - no network
    // - no time-based values
    // - only filesystem presence checks in canonical relative locations
    let mut notes: Vec<String> = Vec::new();

    let authority_candidates = [
        "authority/root.key",
        "authority/root.ed25519",
        "keys/root.key",
        "keys/root.ed25519",
        "core/authority/root.key",
        "core/keys/root.key",
    ];

    let ledger_candidates = [
        "ledger/ledger.log",
        "ledger/ledger.jsonl",
        "ledger/receipts.jsonl",
        "receipts/receipts.jsonl",
        "core/ledger/ledger.jsonl",
        "core/ledger/ledger.log",
    ];

    let authority_path = first_existing_path(&authority_candidates);
    let ledger_path = first_existing_path(&ledger_candidates);

    if authority_path.is_none() {
        notes.push("authority_key_not_found_in_default_locations".to_string());
    }
    if ledger_path.is_none() {
        notes.push("ledger_not_found_in_default_locations".to_string());
    }

    ContractReport {
        ok: true,
        odin_core_version: env!("CARGO_PKG_VERSION"),
        authority_key_found: authority_path.is_some(),
        authority_key_path: authority_path,
        ledger_found: ledger_path.is_some(),
        ledger_path: ledger_path,
        notes,
    }
}

pub fn verify_json() -> String {
    serde_json::to_string_pretty(&verify_report()).unwrap_or_else(|_| "{\"ok\":false}".to_string())
}
