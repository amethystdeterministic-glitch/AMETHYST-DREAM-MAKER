use std::collections::HashMap;

use crate::brains::BrainSpec;

#[derive(Default)]
pub struct BrainRegistry {
    brains: HashMap<String, BrainSpec>,
}

impl BrainRegistry {
    pub fn new() -> Self {
        Self { brains: HashMap::new() }
    }

    pub fn register(&mut self, spec: BrainSpec) {
        self.brains.insert(spec.name.clone(), spec);
    }

    pub fn get(&self, name: &str) -> Option<&BrainSpec> {
        self.brains.get(name)
    }

    pub fn list(&self) -> Vec<&BrainSpec> {
        self.brains.values().collect()
    }
}
