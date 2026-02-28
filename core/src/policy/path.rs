pub fn allowed_prefixes() -> Vec<&'static str> {
    vec![
        "/data/data/com.termux/files/home/repos/odin_os/",
        "/data/data/com.termux/files/home/amethyst/",
    ]
}

pub fn validate_path(path: &str) -> Result<(), String> {
    if allowed_prefixes().iter().any(|p| path.starts_with(p)) {
        Ok(())
    } else {
        Err(format!("Path '{}' violates allowlist", path))
    }
}
