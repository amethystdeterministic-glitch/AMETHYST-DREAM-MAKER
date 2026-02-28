#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CoreState {
    Green,
    Red,
    Blocked,
}

impl CoreState {
    pub fn is_mutable(&self) -> bool {
        matches!(self, CoreState::Green)
    }
}
