use anyhow::Result;

mod bridge {
    pub mod v19;
}

mod scoring;
mod survival;
mod data;
mod contract;
mod signature;
mod artifacts;

fn main() -> Result<()> {
    println!("===============================");
    println!("BRCA V20 — RUST ENGINE START");
    println!("===============================");

    let dataset = "/data/data/com.termux/files/home/repos/odin_os/datasets/brca_v20/train_tcga_real_recovered.csv";
    let sig_path = "/data/data/com.termux/files/home/repos/odin_os/datasets/brca_v20/brca_sig_v1_phase2_lock.json";
    let artifact_root = "/data/data/com.termux/files/home/repos/odin_os/artifacts/brca_v20";

    println!("[STATUS] Phase 13 — V20 first, V19 validation only");

    let report = match contract::validate_csv(dataset, 20) {
        Ok(r) => r,
        Err(e) => {
            println!("[CONTRACT FAIL] {}", e);
            println!("[STATUS] Falling back to V19");
            bridge::v19::run_v19();
            return Ok(());
        }
    };

    println!("[CONTRACT OK] gene_like_columns={}", report.gene_like_columns);

    let sig = match signature::load_signature(sig_path) {
        Ok(s) => s,
        Err(e) => {
            println!("[SIGNATURE FAIL] {}", e);
            println!("[STATUS] Falling back to V19");
            bridge::v19::run_v19();
            return Ok(());
        }
    };

    println!("[SIGNATURE OK] id={}", sig.signature_id);
    println!("[SIGNATURE OK] gene_count={}", sig.gene_count);

    let records = match data::reader::load_dataset_with_signature(dataset, &sig.genes) {
        Ok(r) => r,
        Err(e) => {
            println!("[DATA FAIL] {}", e);
            println!("[STATUS] Falling back to V19");
            bridge::v19::run_v19();
            return Ok(());
        }
    };

    println!("[DATA] Loaded {} records", records.len());

    let summary = survival::run_survival(&records);

    println!("[RESULT]");
    println!("LOW GROUP AVG SCORE: {}", summary.low_group_avg_score);
    println!("HIGH GROUP AVG SCORE: {}", summary.high_group_avg_score);
    println!("LOW GROUP AVG SURVIVAL: {}", summary.low_group_avg_survival);
    println!("HIGH GROUP AVG SURVIVAL: {}", summary.high_group_avg_survival);
    println!("LOW GROUP EVENTS: {}", summary.low_group_events);
    println!("HIGH GROUP EVENTS: {}", summary.high_group_events);
    println!("LOW GROUP TIME SUM: {}", summary.low_group_time_sum);
    println!("HIGH GROUP TIME SUM: {}", summary.high_group_time_sum);

    match summary.hazard_ratio {
        Some(hr) => println!("HAZARD RATIO: {}", hr),
        None => println!("HAZARD RATIO: UNDEFINED"),
    }

    println!("SIGNAL: {}", summary.signal);

    let out_dir = artifacts::write_outputs(
        artifact_root,
        dataset,
        sig_path,
        &sig,
        &records,
        &summary,
    )?;

    println!("[ARTIFACTS OK] {}", out_dir);

    println!("[STATUS] Running V19 in validation-only mode");
    bridge::v19::run_v19();

    Ok(())
}
