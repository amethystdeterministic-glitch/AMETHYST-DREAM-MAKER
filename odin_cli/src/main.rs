use std::process;

fn env_default(k: &str, d: &str) -> String {
    std::env::var(k).unwrap_or_else(|_| d.to_string())
}

fn default_paths() -> (String, String, String) {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    let key = env_default("ODIN_KEY_PATH", &format!("{home}/.odin/keys/authority.key"));
    let pubk = env_default("ODIN_PUB_PATH", &format!("{home}/.odin/keys/authority.pub"));
    let ledger = env_default("ODIN_LEDGER_PATH", &format!("{home}/.odin/ledger/ledger.jsonl"));
    (key, pubk, ledger)
}

fn json_exit(ok: bool, v: serde_json::Value, code: i32) -> ! {
    let mut out = v;
    out["ok"] = serde_json::json!(ok);
    println!(
        "{}",
        serde_json::to_string_pretty(&out).unwrap_or_else(|_| format!("{{\"ok\":{}}}", ok))
    );
    process::exit(code);
}

fn json_fail(msg: &str) -> ! {
    json_exit(false, serde_json::json!({ "error": msg }), 1)
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage:");
        eprintln!("  odin_cli verify");
        eprintln!("  odin_cli keygen [--key-path PATH] [--pub-path PATH]");
        eprintln!("  odin_cli commit-translation --source TEXT --target TEXT [--key-path PATH] [--pub-path PATH] [--ledger-path PATH]");
        process::exit(1);
    }

    match args[1].as_str() {
        "keygen" => {
            let (mut key_path, mut pub_path, _) = default_paths();
            let mut i = 2usize;
            while i < args.len() {
                match args[i].as_str() {
                    "--key-path" => { i += 1; key_path = args.get(i).cloned().unwrap_or(key_path); }
                    "--pub-path" => { i += 1; pub_path = args.get(i).cloned().unwrap_or(pub_path); }
                    _ => {}
                }
                i += 1;
            }

            if let Err(e) = odin_core::translation::ensure_keypair(&key_path, &pub_path) {
                json_fail(&e);
            }

            json_exit(true, serde_json::json!({
                "msg": "KEYGEN_OK",
                "key_path": key_path,
                "pub_path": pub_path
            }), 0);
        }

        "commit-translation" => {
            let (mut key_path, mut pub_path, mut ledger_path) = default_paths();
            let mut source: Option<String> = None;
            let mut target: Option<String> = None;

            let mut i = 2usize;
            while i < args.len() {
                match args[i].as_str() {
                    "--source" => { i += 1; source = args.get(i).cloned(); }
                    "--target" => { i += 1; target = args.get(i).cloned(); }
                    "--key-path" => { i += 1; key_path = args.get(i).cloned().unwrap_or(key_path); }
                    "--pub-path" => { i += 1; pub_path = args.get(i).cloned().unwrap_or(pub_path); }
                    "--ledger-path" => { i += 1; ledger_path = args.get(i).cloned().unwrap_or(ledger_path); }
                    _ => {}
                }
                i += 1;
            }

            let source = source.unwrap_or_else(|| { eprintln!("missing --source"); process::exit(1) });
            let target = target.unwrap_or_else(|| { eprintln!("missing --target"); process::exit(1) });

            // Fail-closed: key must exist to commit
            if std::fs::metadata(&key_path).is_err() || std::fs::metadata(&pub_path).is_err() {
                json_fail("authority keypair missing; run: odin_cli keygen");
            }

            // Ensure ledger dir exists for commit only
            if let Some(parent) = std::path::Path::new(&ledger_path).parent() {
                if let Err(e) = std::fs::create_dir_all(parent) {
                    json_fail(&format!("create ledger dir: {e}"));
                }
            }
            if std::fs::metadata(&ledger_path).is_err() {
                if let Err(e) = std::fs::write(&ledger_path, b"") {
                    json_fail(&format!("create ledger: {e}"));
                }
            }

            let block = match odin_core::translation::commit_translation(
                &source, &target, &key_path, &pub_path, &ledger_path
            ) {
                Ok(b) => b,
                Err(e) => json_fail(&e),
            };

            println!("{}", serde_json::to_string_pretty(&block).unwrap_or_else(|_| "{\"ok\":false}".to_string()));
            process::exit(0);
        }

        "verify" => {
            let (key_path, pub_path, ledger_path) = default_paths();

            let key_ok = std::fs::metadata(&key_path).is_ok() && std::fs::metadata(&pub_path).is_ok();
            let ledger_ok = std::fs::metadata(&ledger_path).is_ok();

            // Start from contract JSON if it parses; otherwise provide minimal base
            let base_str = odin_core::contract::verify_json();
            let mut base: serde_json::Value = serde_json::from_str(&base_str)
                .unwrap_or_else(|_| serde_json::json!({"odin_core_version": "unknown"}));

            base["authority_key_found"] = serde_json::json!(key_ok);
            base["authority_key_path"] = if key_ok { serde_json::json!(key_path.clone()) } else { serde_json::Value::Null };
            base["ledger_found"] = serde_json::json!(ledger_ok);
            base["ledger_path"] = if ledger_ok { serde_json::json!(ledger_path.clone()) } else { serde_json::Value::Null };

            if !key_ok {
                base["translation_blocks_verified"] = serde_json::json!(0);
                json_exit(false, base, 1);
            }
            if !ledger_ok {
                base["translation_blocks_verified"] = serde_json::json!(0);
                json_exit(false, base, 1);
            }

            let verified = match odin_core::translation::verify_ledger(&pub_path, &ledger_path) {
                Ok(n) => n,
                Err(e) => json_fail(&e),
            };

            base["translation_blocks_verified"] = serde_json::json!(verified);
            json_exit(true, base, 0);
        }

        _ => {
            eprintln!("Unknown command");
            process::exit(1);
        }
    }
}
