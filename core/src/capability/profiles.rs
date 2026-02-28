use super::definition::Capability;
use super::registry::CapabilityRegistry;
use crate::policy::role::Role;

pub fn registry_for_role(role: &Role) -> CapabilityRegistry {
    let mut reg = CapabilityRegistry::new();

    match role {
        // Full authority. Can mutate, execute tools, spawn, and use network.
        Role::Sovereign => {
            reg.grant(Capability::FilesystemRead);
            reg.grant(Capability::FilesystemWrite);
            reg.grant(Capability::NetworkOutbound);
            reg.grant(Capability::ProcessSpawn);
            reg.grant(Capability::ToolExecution);
        }

        // Operational role: can execute approved tools and read/write within policy,
        // but no process spawning by default, and no network by default.
        Role::Operator => {
            reg.grant(Capability::FilesystemRead);
            reg.grant(Capability::FilesystemWrite);
            reg.grant(Capability::ToolExecution);
        }

        // Observer role: read-only. No mutation, no tool execution, no spawn, no network.
        Role::Observer => {
            reg.grant(Capability::FilesystemRead);
        }
    }

    reg
}
