use std::env;
use std::fs::{File, remove_file};
use std::io::Write;
use std::path::Path;
use std::process::{Command, Child};
use std::thread::sleep;
use std::time::Duration;

const LOCK_FILE: &str = "/data/data/com.termux/files/home/odin_runtime/runtime.lock";
const QWEN_PORT: &str = "8081";
const CODER_PORT: &str = "8082";

const LLAMA_SERVER: &str = "/data/data/com.termux/files/home/odin_runtime/bin/llama-server";
const QWEN_MODEL: &str = "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-3b-instruct-q4_k_m.gguf";
const CODER_MODEL: &str = "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-coder-3b-q8_0.gguf";

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        println!("Usage: amethystctl <on|off|status|reboot>");
        return;
    }

    match args[1].as_str() {
        "on" => power_on(),
        "off" => power_off(),
        "status" => status(),
        "reboot" => {
            power_off();
            sleep(Duration::from_secs(1));
            power_on();
        }
        _ => println!("Invalid command"),
    }
}

fn power_on() {
    if Path::new(LOCK_FILE).exists() {
        println!("Runtime already ON.");
        return;
    }

    println!("Starting Qwen...");
    let _qwen = spawn_server(QWEN_MODEL, QWEN_PORT);

    println!("Starting Qwen Coder...");
    let _coder = spawn_server(CODER_MODEL, CODER_PORT);

    sleep(Duration::from_secs(2));

    create_lock();
    println!("Runtime GREEN.");
}

fn power_off() {
    if !Path::new(LOCK_FILE).exists() {
        println!("Runtime already OFF.");
        return;
    }

    println!("Stopping services...");
    kill_port(QWEN_PORT);
    kill_port(CODER_PORT);

    let _ = remove_file(LOCK_FILE);
    println!("Runtime OFF.");
}

fn status() {
    if Path::new(LOCK_FILE).exists() {
        println!("Runtime is ON.");
    } else {
        println!("Runtime is OFF.");
    }
}

fn spawn_server(model: &str, port: &str) -> Child {
    Command::new(LLAMA_SERVER)
        .args([
            "--host", "127.0.0.1",
            "--port", port,
            "-m", model,
        ])
        .spawn()
        .expect("Failed to start server")
}

fn kill_port(port: &str) {
    let _ = Command::new("pkill")
        .arg("-f")
        .arg(port)
        .status();
}

fn create_lock() {
    let mut file = File::create(LOCK_FILE).expect("Unable to create lock file");
    file.write_all(b"AMETHYST_RUNTIME_ACTIVE").unwrap();
}
