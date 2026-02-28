#[derive(Debug, Clone)]
pub enum Brain {
    Qwen,
    QwenCoder,
}

pub fn select_brain(request: &str) -> Brain {
    // Deterministic rule (no AI involved)
    if request.contains("fn ")
        || request.contains("struct ")
        || request.contains("impl ")
        || request.contains("cargo ")
        || request.contains("rust")
        || request.contains("code")
    {
        Brain::QwenCoder
    } else {
        Brain::Qwen
    }
}
pub mod dispatch;
