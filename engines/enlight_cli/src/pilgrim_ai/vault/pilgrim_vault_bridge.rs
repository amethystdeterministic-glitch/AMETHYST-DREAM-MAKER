use crate::vault_engine::storage::vault_store::VaultStore;

pub struct PilgrimVaultBridge;

impl PilgrimVaultBridge {

    pub fn persist_discovery(vault: &mut VaultStore, signal: &str) {
        vault.store("DiscoveryEngine", signal, "Discovery artifact persisted by Pilgrim.");
    }

    pub fn persist_course(vault: &mut VaultStore, course_id: &str) {
        vault.store("EnlightEngine", course_id, "Training artifact persisted by Pilgrim.");
    }

    pub fn persist_identity_upgrade(vault: &mut VaultStore, capability: &str) {
        vault.store("IdentityEngine", capability, "Identity capability upgrade persisted.");
    }

}
