use ed25519_dalek::{SigningKey, VerifyingKey, Signature, Signer, Verifier};
use rand_core::OsRng;

pub struct AuthorityRoot {
    signing: SigningKey,
    verifying: VerifyingKey,
}

impl AuthorityRoot {
    pub fn new_ephemeral() -> Self {
        let signing = SigningKey::generate(&mut OsRng);
        let verifying = signing.verifying_key();
        Self { signing, verifying }
    }

    pub fn sign(&self, msg: &[u8]) -> Signature {
        self.signing.sign(msg)
    }

    pub fn verify(&self, msg: &[u8], sig: &Signature) -> bool {
        self.verifying.verify(msg, sig).is_ok()
    }
}
