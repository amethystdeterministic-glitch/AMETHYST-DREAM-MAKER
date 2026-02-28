use std::collections::HashSet;
use super::definition::Capability;

pub struct CapabilityRegistry {
    granted: HashSet<Capability>,
}

impl CapabilityRegistry {
    pub fn new() -> Self {
        Self {
            granted: HashSet::new(),
        }
    }

    pub fn grant(&mut self, cap: Capability) {
        self.granted.insert(cap);
    }

    pub fn has(&self, cap: &Capability) -> bool {
        self.granted.contains(cap)
    }

    pub fn list(&self) -> Vec<Capability> {
        let mut v: Vec<Capability> = self.granted.iter().cloned().collect();
        v.sort_by(|a, b| format!("{:?}", a).cmp(&format!("{:?}", b)));
        v
    }
}
