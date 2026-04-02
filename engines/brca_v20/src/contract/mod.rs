use anyhow::{bail, Result};
use csv::Reader;
use std::collections::HashSet;

#[derive(Debug, Clone)]
pub struct DataContractReport {
    pub path: String,
    pub column_count: usize,
    pub row_preview_count: usize,
    pub has_sample_id: bool,
    pub gene_like_columns: usize,
    pub numeric_preview_ok: bool,
    pub gene_headers: Vec<String>,
}

fn looks_like_sample_id(name: &str) -> bool {
    let n = name.trim().to_ascii_lowercase();
    matches!(n.as_str(), "sample_id" | "sampleid" | "sample" | "id")
}

fn looks_like_meta_column(name: &str) -> bool {
    let n = name.trim().to_ascii_lowercase();
    matches!(
        n.as_str(),
        "sample_id" | "sampleid" | "sample" | "id" | "time" | "event" | "group" | "score"
    )
}

fn looks_like_gene_symbol(name: &str) -> bool {
    if name.is_empty() {
        return false;
    }
    let chars: Vec<char> = name.chars().collect();
    chars.iter().all(|c| c.is_ascii_uppercase() || c.is_ascii_digit())
        && chars.iter().any(|c| c.is_ascii_uppercase())
}

pub fn validate_csv(path: &str, min_gene_columns: usize) -> Result<DataContractReport> {
    let mut rdr = Reader::from_path(path)?;
    let headers = rdr.headers()?.clone();

    let column_count = headers.len();
    let has_sample_id = headers.iter().any(looks_like_sample_id);

    let gene_headers: Vec<String> = headers
        .iter()
        .filter(|h| !looks_like_meta_column(h))
        .filter(|h| looks_like_gene_symbol(h))
        .map(|h| h.to_string())
        .collect();

    let gene_like_columns = gene_headers.len();

    let mut numeric_preview_ok = true;
    let mut row_preview_count = 0usize;

    for result in rdr.records().take(5) {
        let record = result?;
        row_preview_count += 1;

        for (i, field) in record.iter().enumerate() {
            let h = &headers[i];
            if looks_like_meta_column(h) {
                continue;
            }
            if field.trim().is_empty() {
                continue;
            }
            if field.parse::<f64>().is_err() {
                numeric_preview_ok = false;
            }
        }
    }

    let report = DataContractReport {
        path: path.to_string(),
        column_count,
        row_preview_count,
        has_sample_id,
        gene_like_columns,
        numeric_preview_ok,
        gene_headers,
    };

    if !report.has_sample_id {
        bail!("Dataset rejected: missing sample_id-style column");
    }

    if report.gene_like_columns < min_gene_columns {
        bail!(
            "Dataset rejected: gene-like columns below minimum (found {}, need >= {})",
            report.gene_like_columns,
            min_gene_columns
        );
    }

    if !report.numeric_preview_ok {
        bail!("Dataset rejected: non-numeric values detected in previewed gene columns");
    }

    Ok(report)
}

pub fn compare_gene_sets(train: &DataContractReport, valid: &DataContractReport, min_common: usize) -> Result<usize> {
    let train_set: HashSet<&str> = train.gene_headers.iter().map(|s| s.as_str()).collect();
    let valid_set: HashSet<&str> = valid.gene_headers.iter().map(|s| s.as_str()).collect();

    let common = train_set.intersection(&valid_set).count();

    if common < min_common {
        bail!(
            "Cross-cohort rejected: common gene set below minimum (found {}, need >= {})",
            common,
            min_common
        );
    }

    Ok(common)
}
