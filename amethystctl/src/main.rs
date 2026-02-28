use std::env;
use std::fs::{self, File};
use std::io::{Read, Write};
use std::net::TcpStream;
use std::process::{Command, Stdio};
use std::thread::sleep;
use std::time::{Duration, Instant};

const LLAMA_SERVER: &str =
    "/data/data/com.termux/files/home/odin_runtime/bin/llama-server";

const QWEN_MODEL: &str =
    "/data/data/com.termux/files/home/odin_runtime/models/qwen2.5-3b-instruct-q4_k_m.gguf";

const QWEN_PORT: u16 = 8081;

const QWEN_PID: &str =
    "/data/data/com.termux/files/home/odin_runtime/qwen.pid";

const QWEN_LOG: &str =
    "/data/data/com.termux/files/home/odin_runtime/logs/qwen.log";

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        println!("Usage: amethystctl <on|off|status|reboot>");
        return;
    }

    match args[1].as_str() {
        "on" => cmd_on(),
        "off" => cmd_off(),
        "status" => cmd_status(),
        "reboot" => {
            cmd_off();
            sleep(Duration::from_millis(500));
            cmd_on();
        }
        _ => println!("Invalid command"),
    }
}

fn cmd_on() {
    if pid_alive(read_pid()) {
        println!("Runtime already ON.");
        return;
    }

    println!("Starting Qwen (8081)...");

    let pid = spawn_llama().expect("Failed to spawn llama-server");
    write_pid(pid).expect("Failed to write PID");

    println!("Waiting for health...");

    if !poll_health(Duration::from_secs(20)) {
        println!("Health check failed.");
        let _ = kill_pid(pid);
        let _ = fs::remove_file(QWEN_PID);
        return;
    }

    println!("Runtime GREEN.");
}

fn cmd_off() {
    if let Some(pid) = read_pid() {
        if pid_alive(Some(pid)) {
            println!("Stopping Qwen...");
            let _ = kill_pid(pid);
        }
        let _ = fs::remove_file(QWEN_PID);
    }

    println!("Runtime OFF.");
}

fn cmd_status() {
    let pid = read_pid();
    let running = pid_alive(pid);

    println!("Qwen: {}", if running { "RUNNING" } else { "STOPPED" });
    println!("Health: {}", if health_ok() { "HEALTHY" } else { "NO" });
}

fn spawn_llama() -> Result<u32, String> {
    let log_file = File::options()
        .create(true)
        .append(true)
        .open(QWEN_LOG)
        .map_err(|e| e.to_string())?;

    let log_file_err = log_file.try_clone().map_err(|e| e.to_string())?;

    let child = Command::new(LLAMA_SERVER)
        .args([
            "--host", "127.0.0.1",
            "--port", &QWEN_PORT.to_string(),
            "-m", QWEN_MODEL,
        ])
        .stdout(Stdio::from(log_file))
        .stderr(Stdio::from(log_file_err))
        .spawn()
        .map_err(|e| e.to_string())?;

    Ok(child.id())
}

fn poll_health(timeout: Duration) -> bool {
    let deadline = Instant::now() + timeout;
    while Instant::now() < deadline {
        if health_ok() {
            return true;
        }
        sleep(Duration::from_millis(300));
    }
    false
}

fn health_ok() -> bool {
    let addr = format!("127.0.0.1:{}", QWEN_PORT);
    let mut stream = match TcpStream::connect(addr) {
        Ok(s) => s,
        Err(_) => return false,
    };

    let req = "GET /v1/models HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n";

    if stream.write_all(req.as_bytes()).is_err() {
        return false;
    }

    let mut buf = [0u8; 256];
    let n = match stream.read(&mut buf) {
        Ok(n) => n,
        Err(_) => return false,
    };

    let head = String::from_utf8_lossy(&buf[..n]);
    head.contains("200")
}

fn read_pid() -> Option<u32> {
    fs::read_to_string(QWEN_PID).ok()?.trim().parse().ok()
}

fn write_pid(pid: u32) -> Result<(), String> {
    fs::write(QWEN_PID, format!("{}\n", pid)).map_err(|e| e.to_string())
}

fn pid_alive(pid: Option<u32>) -> bool {
    if let Some(p) = pid {
        Command::new("kill")
            .arg("-0")
            .arg(p.to_string())
            .status()
            .map(|s| s.success())
            .unwrap_or(false)
    } else {
        false
    }
}

fn kill_pid(pid: u32) -> Result<(), String> {
    Command::new("kill")
        .arg("-TERM")
        .arg(pid.to_string())
        .status()
        .map_err(|e| e.to_string())?;
    Ok(())
}
