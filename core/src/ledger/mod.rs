use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use crate::authority::AuthorityRoot;
use crate::state::CoreState;
use ed25519_dalek::Signature;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct LedgerEntry {
    pub id: u64,
    pub kind: String,
    pub prev_hash: String,
    pub entry_hash: String,
    pub authority_sig: Vec<u8>,
    pub payload: serde_json::Value,
}

pub struct Ledger {
    entries: Vec<LedgerEntry>,
}

impl Ledger {
    pub fn new() -> Self {
        Self { entries: Vec::new() }
    }

    pub fn len(&self) -> usize {
        self.entries.len()
    }

    pub fn tip_hash(&self) -> String {
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

        // Hash over canonical-ish bytes: entry with empty hash+sig fields.
        let bytes = serde_json::to_vec(&entry).unwrap();
        let mut hasher = Sha256::new();
        hasher.update(&bytes);
        let hash = hasher.finalize();
        entry.entry_hash = format!("{:x}", hash);

        let sig = authority.sign(entry.entry_hash.as_bytes());
        entry.authority_sig = sig.to_bytes().to_vec();

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

    // -------- Lifecycle helpers (Stage 3) --------

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
}
