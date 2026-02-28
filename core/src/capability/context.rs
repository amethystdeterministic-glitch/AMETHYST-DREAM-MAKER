use super::definition::Capability;
use super::registry::CapabilityRegistry;

pub struct CapabilityContext {
    registry: CapabilityRegistry,
}

impl CapabilityContext {
    pub fn new(registry: CapabilityRegistry) -> Self {
        Self { registry }
    }

    pub fn require(&self, cap: Capability) -> Result<(), String> {
        if self.registry.has(&cap) {
            Ok(())
        } else {
            Err(format!("Capability {:?} not granted", cap))
        }
    }

    pub fn registry_list(&self) -> Vec<Capability> {
        self.registry.list()
    }
}
