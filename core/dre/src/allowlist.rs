pub fn is_allowed(action: &str) -> bool {
    matches!(action, "deploy" | "test" | "status")
}
