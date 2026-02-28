use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use crate::authority::AuthorityRoot;
use crate::state::CoreState;
use ed25519_dalek::Signature;
use std::fs::{OpenOptions, File};
use std::io::{Write, BufRead, BufReader};
use std::path::Path;

const LEDGER_FILE: &str = "odin_ledger.jsonl";

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct LedgerEntry {
    pub id: u64,
    pub kind: String,
    pub prev_hash: String,
    pub entry_hash: String,
    pub authority_sig: Vec<u8>,
    pub payload: serde_json::Value,
}

enum LedgerBackend {
    Memory,
    File,
}

pub struct Ledger {
    entries: Vec<LedgerEntry>,
    backend: LedgerBackend,
}

impl Ledger {
    pub fn new_in_memory() -> Self {
        Self { entries: Vec::new(), backend: LedgerBackend::Memory }
    }

    pub fn load(authority: &AuthorityRoot) -> Result<Self, &'static str> {
        if !Path::new(LEDGER_FILE).exists() {
            return Ok(Self { entries: Vec::new(), backend: LedgerBackend::File });
        }

        let file = File::open(LEDGER_FILE).map_err(|_| "Failed to open ledger")?;
        let reader = BufReader::new(file);

        let mut entries = Vec::new();
        for line in reader.lines() {
            let line = line.map_err(|_| "Failed to read ledger line")?;
            if line.trim().is_empty() { continue; }
            let entry: LedgerEntry = serde_json::from_str(&line).map_err(|_| "Invalid ledger entry")?;
            entries.push(entry);
        }

        let ledger = Self { entries, backend: LedgerBackend::File };

        if !ledger.verify_chain(authority) {
            return Err("Ledger corruption detected");
        }

        Ok(ledger)
    }

    pub fn len(&self) -> usize { self.entries.len() }

    fn tip_hash(&self) -> String {
        self.entries
            .last()
            .map(|e| e.entry_hash.clone())
            .unwrap_or_else(|| "0".repeat(64))
    }

    pub fn append_signed(
        &mut self,
        kind: &str,
        payload: serde_json::Value,
        authority: &AuthorityRoot,
        state: CoreState,
    ) -> Result<(), &'static str> {
        if !state.is_mutable() {
            return Err("Core not in GREEN state");
        }

        let id = self.entries.len() as u64;
        let prev_hash = self.tip_hash();

        let mut entry = LedgerEntry {
            id,
            kind: kind.to_string(),
            prev_hash,
            entry_hash: String::new(),
            authority_sig: Vec::new(),
            payload,
        };

        let bytes = serde_json::to_vec(&entry).unwrap();
        let mut hasher = Sha256::new();
        hasher.update(&bytes);
        let hash = hasher.finalize();
        entry.entry_hash = format!("{:x}", hash);

        let sig = authority.sign(entry.entry_hash.as_bytes());
        entry.authority_sig = sig.to_bytes().to_vec();

        if matches!(self.backend, LedgerBackend::File) {
            let mut file = OpenOptions::new()
                .create(true)
                .append(true)
                .open(LEDGER_FILE)
                .map_err(|_| "Failed to open ledger for append")?;

            let line = serde_json::to_string(&entry).unwrap();
            writeln!(file, "{}", line).map_err(|_| "Failed to write ledger entry")?;
        }

        self.entries.push(entry);
        Ok(())
    }

    pub fn verify_chain(&self, authority: &AuthorityRoot) -> bool {
        let mut prev = "0".repeat(64);

        for entry in &self.entries {
            if entry.prev_hash != prev {
                return false;
            }

            let mut clone = entry.clone();
            clone.entry_hash.clear();
            clone.authority_sig.clear();

            let bytes = serde_json::to_vec(&clone).unwrap();
            let mut hasher = Sha256::new();
            hasher.update(bytes);
            let expected_hash = format!("{:x}", hasher.finalize());

            if expected_hash != entry.entry_hash {
                return false;
            }

            if entry.authority_sig.len() != 64 {
                return false;
            }

            let mut sig_bytes = [0u8; 64];
            sig_bytes.copy_from_slice(&entry.authority_sig);

            let sig = Signature::from_bytes(&sig_bytes);

            if !authority.verify(entry.entry_hash.as_bytes(), &sig) {
                return false;
            }

            prev = entry.entry_hash.clone();
        }

        true
    }

    pub fn has_kind_for_intent(&self, kind: &str, intent_id: &str) -> bool {
        self.entries.iter().any(|e| {
            if e.kind != kind { return false; }
            e.payload
                .get("intent_id")
                .and_then(|v| v.as_str())
                .map(|s| s == intent_id)
                .unwrap_or(false)
        })
    }

    pub fn treegate_passed(&self, intent_id: &str) -> bool {
        self.entries.iter().any(|e| {
            if e.kind != "tree_gate" { return false; }
            let pid = e.payload.get("intent_id").and_then(|v| v.as_str()).unwrap_or("");
            let pass = e.payload.get("pass").and_then(|v| v.as_bool()).unwrap_or(false);
            pid == intent_id && pass
        })
    }

    pub fn finalized(&self, intent_id: &str) -> bool {
        self.has_kind_for_intent("finalize", intent_id)
    }

    pub fn executed(&self, intent_id: &str) -> bool {
        self.has_kind_for_intent("execution_receipt", intent_id)
    }

    // -------- Stage 9: read-only export helpers --------

    pub fn entries(&self) -> &[LedgerEntry] {
        &self.entries
    }

    pub fn entries_cloned(&self) -> Vec<LedgerEntry> {
        self.entries.clone()
    }

    pub fn filter_kind(&self, kind: &str) -> Vec<LedgerEntry> {
        self.entries.iter().cloned().filter(|e| e.kind == kind).collect()
    }

    pub fn filter_intent(&self, intent_id: &str) -> Vec<LedgerEntry> {
        self.entries.iter().cloned().filter(|e| {
            e.payload.get("intent_id").and_then(|v| v.as_str()) == Some(intent_id)
        }).collect()
    }
}
