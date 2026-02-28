use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CoreState {
    Green,
    Yellow,
    Red,
}

impl CoreState {
    pub fn is_mutable(&self) -> bool {
        matches!(self, CoreState::Green)
    }
}
