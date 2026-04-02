use std::fs::File;
use std::io::{BufRead, BufReader};

pub struct CsvParser;

impl CsvParser {

    pub fn parse(path: &str) -> usize {

        if let Ok(file) = File::open(path) {
            let reader = BufReader::new(file);
            let mut count = 0;

            for _ in reader.lines() {
                count += 1;
            }

            println!("Parsed {} records", count);
            count
        } else {
            println!("Dataset not found, returning 0");
            0
        }

    }
}
