mod service;

use service::{ServiceConfig, ServiceRegistry};

fn main() {
    let mut registry = ServiceRegistry::new();

    // Canonical runtime locations (no PATH, no ~)
    let llama_server = "/data/data/com.termux/files/home/odin_runtime/bin/llama-server";
    let qwen_model   = "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-3b-instruct-q4_k_m.gguf";

    registry.register(ServiceConfig {
        name: "qwen".into(),
        command: llama_server.into(),
        args: vec![
            "--host".into(), "127.0.0.1".into(),
            "--port".into(), "8081".into(),
            "-m".into(), qwen_model.into(),
        ],
        port: Some(8081),
    });

    match registry.start("qwen") {
        Ok(_) => println!("Service started."),
        Err(e) => eprintln!("Start failed: {}", e),
    }
}
