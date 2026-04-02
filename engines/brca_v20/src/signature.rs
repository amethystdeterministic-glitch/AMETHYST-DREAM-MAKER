use anyhow::{bail, Result};
use serde::Deserialize;
use std::fs;

#[derive(Debug, Deserialize, Clone)]
pub struct SignatureContract {
    pub signature_id: String,
    pub gene_count: usize,
    pub genes: Vec<String>,
}

pub fn load_signature(path: &str) -> Result<SignatureContract> {
    let raw = fs::read_to_string(path)?;
    let sig: SignatureContract = serde_json::from_str(&raw)?;

    if sig.genes.len() != sig.gene_count {
        bail!(
            "Signature contract invalid: gene_count={} but genes.len()={}",
            sig.gene_count,
            sig.genes.len()
        );
    }

    if sig.genes.is_empty() {
        bail!("Signature contract invalid: empty gene list");
    }

    Ok(sig)
}
