use std::fs::File;
use std::io::{BufRead, BufReader};

pub fn load_stream(path: &str) -> Vec<String> {
    let file = File::open(path).expect("failed to open stream");
    let reader = BufReader::new(file);

    reader.lines().map(|l| l.unwrap()).collect()
}
