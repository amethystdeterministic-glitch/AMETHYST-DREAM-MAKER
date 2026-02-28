#[derive(Debug, Clone)]
pub enum Role {
    Sovereign,
    Operator,
    Observer,
}

pub fn validate_role(role: &Role, action: &str) -> Result<(), String> {
    match role {
        Role::Sovereign => Ok(()),
        Role::Operator => {
            if action == "forge_execute" {
                Ok(())
            } else {
                Err("Operator not permitted for this action".into())
            }
        }
        Role::Observer => Err("Observer cannot mutate state".into()),
    }
}
