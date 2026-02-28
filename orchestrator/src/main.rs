mod service;

use service::{ServiceConfig, ServiceRegistry};

fn main() {
    let mut registry = ServiceRegistry::new();

    let llama_server = "/data/data/com.termux/files/home/odin_runtime/bin/llama-server";

    // Qwen Instruct (8081)
    registry.register(ServiceConfig {
        name: "qwen".into(),
        command: llama_server.into(),
        args: vec![
            "--host".into(), "127.0.0.1".into(),
            "--port".into(), "8081".into(),
            "-m".into(),
            "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-3b-instruct-q4_k_m.gguf".into(),
        ],
        port: Some(8081),
    });

    // Qwen Coder (8082)
    registry.register(ServiceConfig {
        name: "qwen_coder".into(),
        command: llama_server.into(),
        args: vec![
            "--host".into(), "127.0.0.1".into(),
            "--port".into(), "8082".into(),
            "-m".into(),
            "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-coder-3b-q8_0.gguf".into(),
        ],
        port: Some(8082),
    });

    for name in ["qwen", "qwen_coder"] {
        match registry.start(name) {
            Ok(_) => println!("Service started: {}", name),
            Err(e) => println!("Start failed ({}): {}", name, e),
        }
    }
}
