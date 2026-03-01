use std::process::Command;
use std::io::{self, Write};
use std::thread;
use std::time::Duration;
use reqwest::blocking::Client;
use serde::Deserialize;

#[derive(Deserialize)]
struct QueryResp {
    ok: bool,
    pilgrim: String,
    error: Option<String>,
}

fn speak(text: &str) {
    let sentences: Vec<&str> = text.split_terminator('.').collect();

    for s in sentences {
        let clean = s.trim();
        if !clean.is_empty() {
            let line = format!("{}.", clean);
            let _ = Command::new("termux-tts-speak")
                .arg(&line)
                .status();

            thread::sleep(Duration::from_millis(300));
        }
    }
}

fn main() {
    let client = Client::new();
    let mut session_context: Vec<String> = Vec::new();

    println!("Pilgrim Voice Mode — Deterministic Advisory");
    println!("Type /voice to speak, /exit to quit");

    loop {
        print!("you> ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        let input = input.trim();

        if input == "/exit" {
            println!("pilgrim> Session terminated.");
            speak("Session terminated.");
            break;
        }

        let spoken = if input == "/voice" {
            println!("Listening...");

            let output = Command::new("termux-speech-to-text")
                .output();

            match output {
                Ok(out) => {
                    let text = String::from_utf8_lossy(&out.stdout).trim().to_string();
                    if text.is_empty() {
                        println!("speech capture failed");
                        continue;
                    }
                    println!("you (voice)> {}", text);
                    text
                }
                Err(_) => {
                    println!("speech capture failed");
                    continue;
                }
            }
        } else {
            input.to_string()
        };

        session_context.push(format!("User: {}", spoken));
        if session_context.len() > 5 {
            session_context.remove(0);
        }

        let context_block = session_context.join("\n");

        let resp = client.post("http://127.0.0.1:1898/pilgrim/query")
            .json(&serde_json::json!({ "input": context_block }))
            .send();

        let resp = match resp {
            Ok(r) => r,
            Err(_) => {
                println!("pilgrim error");
                continue;
            }
        };

        let parsed = resp.json::<QueryResp>();

        let parsed = match parsed {
            Ok(p) => p,
            Err(_) => {
                println!("pilgrim error");
                continue;
            }
        };

        if parsed.ok {
            println!("pilgrim> {}", parsed.pilgrim);
            speak(&parsed.pilgrim);

            session_context.push(format!("Pilgrim: {}", parsed.pilgrim));
            if session_context.len() > 5 {
                session_context.remove(0);
            }
        } else {
            println!("pilgrim error");
        }
    }
}
