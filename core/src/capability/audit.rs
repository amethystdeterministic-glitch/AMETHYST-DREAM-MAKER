use crate::capability::definition::Capability;
use crate::policy::role::Role;

#[derive(Debug, Clone)]
pub struct CapabilityAudit {
    pub role: Role,
    pub tool: String,
    pub derived: Vec<Capability>,
    pub required: Vec<Capability>,
}

impl CapabilityAudit {
    pub fn to_line(&self) -> String {
        format!(
            "CAP_AUDIT role={:?} tool={} derived={:?} required={:?}",
            self.role, self.tool, self.derived, self.required
        )
    }
}
