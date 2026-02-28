mod service;

use service::{ServiceConfig, ServiceRegistry};

fn main() {
    let mut registry = ServiceRegistry::new();

    registry.register(ServiceConfig {
        name: "qwen".into(),
        command: "/data/data/com.termux/files/home/odin_runtime/bin/llama-server".into(),
        args: vec![
            "-m".into(),
            "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-3b-instruct-q4_k_m.gguf".into(),
            "--host".into(),
            "127.0.0.1".into(),
            "--port".into(),
            "8081".into(),
        ],
        port: Some(8081),
    });

    match registry.start("qwen") {
        Ok(_) => println!("Service started."),
        Err(e) => eprintln!("Start failed: {:?}", e),
    }
}
