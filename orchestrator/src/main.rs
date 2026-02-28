mod service;

use service::{ServiceConfig, ServiceRegistry};

fn main() {
    let mut registry = ServiceRegistry::new();

    registry.register(ServiceConfig {
        name: "qwen".into(),
        command: "llama-server".into(),
        args: vec![
            "-m".into(),
            "~/amethyst/brains/qwen/qwen2.5-3b-instruct-q4_k_m.gguf".into(),
            "--port".into(),
            "8081".into(),
        ],
        port: Some(8081),
    });

    match registry.start("qwen") {
        Ok(_) => println!("Service started."),
        Err(e) => println!("Start failed: {}", e),
    }
}
