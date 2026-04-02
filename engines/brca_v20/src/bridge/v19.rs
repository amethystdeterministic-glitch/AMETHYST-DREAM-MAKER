use std::process::Command;

pub fn run_v19() {
    println!("[V20] Invoking V19 engine...");

    let cmd = "cd ~/repos/odin_os/engines/brca_v19 && bash run_v19.sh";

    let output = Command::new("bash")
        .arg("-c")
        .arg(cmd)
        .output();

    match output {
        Ok(out) => {
            println!("[V19 STDOUT]");
            println!("{}", String::from_utf8_lossy(&out.stdout));

            println!("[V19 STDERR]");
            println!("{}", String::from_utf8_lossy(&out.stderr));
        }
        Err(e) => {
            println!("[ERROR] Failed to execute V19: {}", e);
        }
    }
}
