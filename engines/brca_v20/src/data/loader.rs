use anyhow::Result;
use csv::Reader;

pub fn inspect_csv(path: &str, preview_rows: usize) -> Result<()> {
    println!("[DATA] Loading: {}", path);

    let mut rdr = Reader::from_path(path)?;
    let headers = rdr.headers()?.clone();

    println!("[DATA] Columns: {}", headers.len());
    println!("[DATA] Header Preview: {:?}", headers);

    let mut count = 0usize;

    for result in rdr.records().take(preview_rows) {
        let record = result?;
        println!("[ROW {}] {:?}", count, record);
        count += 1;
    }

    println!("[DATA] Preview complete");
    Ok(())
}
