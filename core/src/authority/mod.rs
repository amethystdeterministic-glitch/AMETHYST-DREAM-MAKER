use ed25519_dalek::{SigningKey, VerifyingKey, Signature, Signer, Verifier};
use rand_core::OsRng;
use std::fs;
use std::path::Path;

const KEY_FILE: &str = "odin_authority.key";

pub struct AuthorityRoot {
    signing: SigningKey,
    verifying: VerifyingKey,
}

impl AuthorityRoot {
    pub fn load_or_create() -> Self {
        if Path::new(KEY_FILE).exists() {
            let bytes = fs::read(KEY_FILE).expect("Failed to read key file");
            if bytes.len() != 32 {
                panic!("Invalid authority key length (expected 32 bytes)");
            }
            let mut sk = [0u8; 32];
            sk.copy_from_slice(&bytes);
            let signing = SigningKey::from_bytes(&sk);
            let verifying = signing.verifying_key();
            Self { signing, verifying }
        } else {
            let signing = SigningKey::generate(&mut OsRng);
            fs::write(KEY_FILE, signing.to_bytes()).expect("Failed to write key");
            let verifying = signing.verifying_key();
            Self { signing, verifying }
        }
    }

    pub fn sign(&self, msg: &[u8]) -> Signature {
        self.signing.sign(msg)
    }

    pub fn verify(&self, msg: &[u8], sig: &Signature) -> bool {
        self.verifying.verify(msg, sig).is_ok()
    }
}
