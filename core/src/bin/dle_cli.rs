use std::env;
use odin_core::translation::commit_translation;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: dle_cli <input_text>");
        return;
    }

    let source_text = &args[1];

    // TEMP: placeholder translation (will be replaced by real model later)
    let target_text = format!("CY: {}", source_text);

    let key_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/dle_keys/sign.key";
    let pub_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/dle_keys/pub.key";
    let ledger_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/dle_ledger/ledger.jsonl";

    match commit_translation(
        source_text,
        &target_text,
        key_path,
        pub_path,
        ledger_path,
    ) {
        Ok(block) => {
            println!("{}", serde_json::to_string_pretty(&block).unwrap());
        }
        Err(e) => {
            eprintln!("Error: {}", e);
        }
    }
}
