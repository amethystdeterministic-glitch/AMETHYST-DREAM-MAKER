use anyhow::Result;
use csv::StringRecord;

use crate::data::model::PatientRecord;

pub fn load_dataset_with_signature(
    path: &str,
    genes: &Vec<String>,
) -> Result<Vec<PatientRecord>> {

    println!("[LOADER] START path={}", path);

    let mut rdr = csv::Reader::from_path(path)?;
    let headers = rdr.headers()?.clone();

    println!("[LOADER] header_cols={}", headers.len());

    let mut accepted = 0;
    let mut rejected = 0;

    let mut records = Vec::new();

    for (i, result) in rdr.records().enumerate() {
        let record = result?;

        match parse_record(&record, genes) {
            Ok(r) => {
                accepted += 1;
                if accepted <= 3 {
                    println!("[ACCEPTED SAMPLE] {}", r.sample_id);
                }
                records.push(r);
            }
            Err(e) => {
                rejected += 1;
                if rejected <= 10 {
                    println!("[REJECTED {}] {}", i, e);
                }
            }
        }
    }

    println!("[LOADER] accepted={}", accepted);
    println!("[LOADER] rejected={}", rejected);

    Ok(records)
}

fn parse_record(
    row: &StringRecord,
    genes: &Vec<String>,
) -> Result<PatientRecord> {

    if row.len() < genes.len() + 3 {
        return Err(anyhow::anyhow!("row too short"));
    }

    let sample_id = row.get(0).unwrap_or("").to_string();

    if sample_id.is_empty() {
        return Err(anyhow::anyhow!("missing sample_id"));
    }

    let mut gene_vals = Vec::new();

    for i in 1..=genes.len() {
        let val = row.get(i).unwrap_or("");

        let parsed = val.parse::<f64>()
            .map_err(|_| anyhow::anyhow!("non-numeric gene"))?;

        gene_vals.push(parsed);
    }

    let survival_time = row.get(genes.len() + 1)
        .unwrap_or("0")
        .parse::<f64>()
        .map_err(|_| anyhow::anyhow!("bad survival"))?;

    let event_raw = row.get(genes.len() + 2)
        .unwrap_or("0")
        .parse::<u64>()
        .map_err(|_| anyhow::anyhow!("bad event"))?;

    let event: u8 = match event_raw {
        0 => 0,
        1 => 1,
        _ => return Err(anyhow::anyhow!("invalid event value")),
    };

    Ok(PatientRecord {
        sample_id,
        genes: gene_vals,
        survival_time,
        event,
    })
}
