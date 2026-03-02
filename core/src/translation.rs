use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs::{self, OpenOptions};
use std::io::{BufRead, BufReader, Write};
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

use base64::{engine::general_purpose, Engine as _};
use ed25519_dalek::{Signature, SigningKey, VerifyingKey};
use ed25519_dalek::Signer;
use rand_core::OsRng;

use crate::grammar::apply_mutation_sequence;

#[derive(Serialize, Deserialize)]
pub struct TranslationBlock {
    pub source_lang: String,
    pub target_lang: String,

    // Hashes are stored base64 so ledger stays text-friendly + deterministic.
    pub source_hash_b64: String,
    pub target_hash_b64: String,

    // Signature is over (source_hash || target_hash), base64 encoded.
    pub signature_b64: String,

    pub timestamp: u64,
}

fn now_ts() -> Result<u64, String> {
    Ok(SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map_err(|e| e.to_string())?
        .as_secs())
}

fn ensure_parent_dir(file_path: &str) -> Result<(), String> {
    let p = Path::new(file_path);
    if let Some(parent) = p.parent() {
        fs::create_dir_all(parent).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn write_b64(path: &str, bytes: &[u8]) -> Result<(), String> {
    ensure_parent_dir(path)?;
    let b64 = general_purpose::STANDARD.encode(bytes);
    fs::write(path, b64).map_err(|e| e.to_string())?;
    Ok(())
}

fn read_b64(path: &str) -> Result<Vec<u8>, String> {
    let s = fs::read_to_string(path).map_err(|e| e.to_string())?;
    let s = s.trim();
    general_purpose::STANDARD
        .decode(s.as_bytes())
        .map_err(|e| e.to_string())
}

fn load_signing_key(key_path: &str) -> Result<SigningKey, String> {
    let sk = read_b64(key_path)?;
    let sk: [u8; 32] = sk
        .as_slice()
        .try_into()
        .map_err(|_| "authority.key must be 32 bytes (base64)".to_string())?;
    Ok(SigningKey::from_bytes(&sk))
}

fn load_verifying_key(pub_path: &str) -> Result<VerifyingKey, String> {
    let pk = read_b64(pub_path)?;
    let pk: [u8; 32] = pk
        .as_slice()
        .try_into()
        .map_err(|_| "authority.pub must be 32 bytes (base64)".to_string())?;
    Ok(VerifyingKey::from_bytes(&pk).map_err(|e| e.to_string())?)
}

/// Creates authority keypair if missing.
/// Deterministic storage format:
/// - authority.key: base64(32-byte secret)
/// - authority.pub: base64(32-byte public)
pub fn ensure_keypair(key_path: &str, pub_path: &str) -> Result<(), String> {
    let key_exists = Path::new(key_path).is_file();
    let pub_exists = Path::new(pub_path).is_file();

    if key_exists && pub_exists {
        return Ok(());
    }

    // Create fresh keypair
    let signing = SigningKey::generate(&mut OsRng);
    let verifying = signing.verifying_key();

    write_b64(key_path, &signing.to_bytes())?;
    write_b64(pub_path, &verifying.to_bytes())?;

    Ok(())
}

/// Commit a translation proof block to an append-only JSONL ledger.
/// Canonical Welsh mutation enforcement happens HERE (commit-time only),
/// then the canonical form is hashed + signed.
pub fn commit_translation(
    source_text: &str,
    target_text: &str,
    key_path: &str,
    pub_path: &str,
    ledger_path: &str,
) -> Result<TranslationBlock, String> {
    // ensure keypair exists (auto-heal)
    ensure_keypair(key_path, pub_path)?;

    // load signing key
    let signing = load_signing_key(key_path)?;

    // canonicalize target before hashing (governance-grade determinism)
    let canonical_target = apply_mutation_sequence(target_text);

    let source_hash = Sha256::digest(source_text.as_bytes());
    let target_hash = Sha256::digest(canonical_target.as_bytes());

    let mut msg = Vec::with_capacity(64);
    msg.extend_from_slice(&source_hash);
    msg.extend_from_slice(&target_hash);

    let sig: Signature = signing.sign(&msg);

    let block = TranslationBlock {
        source_lang: "en".to_string(),
        target_lang: "cy".to_string(),
        source_hash_b64: general_purpose::STANDARD.encode(source_hash),
        target_hash_b64: general_purpose::STANDARD.encode(target_hash),
        signature_b64: general_purpose::STANDARD.encode(sig.to_bytes()),
        timestamp: now_ts()?,
    };

    // append JSONL
    ensure_parent_dir(ledger_path)?;
    let serialized = serde_json::to_string(&block).map_err(|e| e.to_string())?;

    let mut f = OpenOptions::new()
        .create(true)
        .append(true)
        .open(ledger_path)
        .map_err(|e| e.to_string())?;

    writeln!(f, "{}", serialized).map_err(|e| e.to_string())?;

    Ok(block)
}

/// Verify all translation blocks in ledger against the public key.
/// NOTE: verification is cryptographic only (signature over hashes).
/// No grammar re-calculation occurs during verify.
pub fn verify_ledger(pub_path: &str, ledger_path: &str) -> Result<usize, String> {
    let vk = load_verifying_key(pub_path)?;

    if !Path::new(ledger_path).is_file() {
        return Ok(0);
    }

    let f = fs::File::open(ledger_path).map_err(|e| e.to_string())?;
    let reader = BufReader::new(f);

    let mut ok_count: usize = 0;

    for (idx, line) in reader.lines().enumerate() {
        let line = line.map_err(|e| e.to_string())?;
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let block: TranslationBlock =
            serde_json::from_str(line).map_err(|e| format!("ledger parse failed line {}: {}", idx, e))?;

        let sh = general_purpose::STANDARD
            .decode(block.source_hash_b64.as_bytes())
            .map_err(|e| format!("source_hash decode failed line {}: {}", idx, e))?;
        let th = general_purpose::STANDARD
            .decode(block.target_hash_b64.as_bytes())
            .map_err(|e| format!("target_hash decode failed line {}: {}", idx, e))?;
        let sb = general_purpose::STANDARD
            .decode(block.signature_b64.as_bytes())
            .map_err(|e| format!("signature decode failed line {}: {}", idx, e))?;

        let sh: [u8; 32] = sh
            .as_slice()
            .try_into()
            .map_err(|_| format!("source_hash wrong size line {}", idx))?;
        let th: [u8; 32] = th
            .as_slice()
            .try_into()
            .map_err(|_| format!("target_hash wrong size line {}", idx))?;
        let sb: [u8; 64] = sb
            .as_slice()
            .try_into()
            .map_err(|_| format!("signature wrong size line {}", idx))?;

        let sig = Signature::from_bytes(&sb);

        let mut msg = Vec::with_capacity(64);
        msg.extend_from_slice(&sh);
        msg.extend_from_slice(&th);

        vk.verify_strict(&msg, &sig)
            .map_err(|e| format!("signature verify failed line {}: {}", idx, e))?;

        ok_count += 1;
    }

    Ok(ok_count)
}
