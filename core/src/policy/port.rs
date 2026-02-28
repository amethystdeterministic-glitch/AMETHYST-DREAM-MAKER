pub fn allowed_ports() -> Vec<u16> {
    vec![8081, 8082, 8090, 7171, 7272, 7878]
}

pub fn validate_port(port: u16) -> Result<(), String> {
    if allowed_ports().contains(&port) {
        Ok(())
    } else {
        Err(format!("Port '{}' not permitted", port))
    }
}
