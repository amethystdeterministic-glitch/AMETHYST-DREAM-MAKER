mod entropy;
mod symmetry;
mod collapse;
mod pilgrimites;
mod svx;
mod temporal_memory;
mod ingest;
mod dag;
mod sfe;
mod signature;
mod trend;
mod normalise;
mod lifecycle;
mod dominance;
mod proximity;
mod competition;

use collapse::dqi_collapse;
use pilgrimites::entropy_agent;
use pilgrimites::symmetry_agent;
use pilgrimites::anomaly_agent;
use svx::evaluate as svx_evaluate;
use temporal_memory::TemporalMemoryState;
use ingest::load_stream;
use dag::allow_anomaly;
use sfe::grammar_score;
use signature::build_signature;
use trend::classify_trend;
use lifecycle::classify_lifecycle;
use dominance::is_dominant;
use proximity::dominance_proximity;
use competition::{rank_clusters, compute_score, ClusterScore};

use std::fs;
use std::collections::HashMap;

fn main() {
    println!("====================================");
    println!("CDS v31 — MULTI-CLUSTER INTELLIGENCE");
    println!("====================================");

    let data_stream = load_stream("seti_stream.txt");

    let mut memory = TemporalMemoryState::new();
    let mut decisions = vec![];
    let mut seen_signatures = HashMap::new();
    let mut cluster_scores: HashMap<String, ClusterScore> = HashMap::new();

    let mut prev_freq = 0;
    let mut prev_runs = 0;

    let state_path = "/data/data/com.termux/files/home/repos/odin_os/artifacts/cluster_state.json";

    if let Ok(state) = fs::read_to_string(state_path) {
        if let Some(freq_part) = state.split("\"freq\":").nth(1) {
            let val = freq_part.split(',').next().unwrap_or("0");
            prev_freq = val.parse::<i32>().unwrap_or(0);
        }
        if let Some(run_part) = state.split("\"runs\":").nth(1) {
            let val = run_part.split(',').next().unwrap_or("0");
            prev_runs = val.parse::<i32>().unwrap_or(0);
        }
    }

    for (i, window) in data_stream.iter().enumerate() {

        let (entropy_val, _) = entropy::entropy_score(window);
        let (symmetry_val_u32, _) = symmetry::symmetry_score(window);
        let symmetry_val = symmetry_val_u32 as i32;

        let (grammar_val, grammar_class) = grammar_score(window);
        let signature = build_signature(window);

        let count = seen_signatures.entry(signature.clone()).or_insert(0);
        *count += 1;

        let mut local = vec![];

        let e = entropy_agent::evaluate(window);
        let s = symmetry_agent::evaluate(window);

        let anomaly_allowed = allow_anomaly(entropy_val, symmetry_val, window);

        let mut a = if anomaly_allowed {
            anomaly_agent::evaluate(window)
        } else {
            ("NOISE".to_string(), 0)
        };

        if grammar_class == "HIGH_STRUCTURE" {
            a.1 += 4;
        } else if grammar_class == "MEDIUM_STRUCTURE" {
            a.1 += 2;
        }

        if *count >= 2 {
            a.1 += 6;
        }

        println!("window={} raw={}", i, window);
        println!("window={} grammar={} ({})", i, grammar_val, grammar_class);
        println!("window={} signature_count={}", i, count);

        let entry = cluster_scores.entry(signature.clone()).or_insert(ClusterScore {
            freq: 0,
            strength: 0.0,
        });

        entry.freq += 1;
        entry.strength = compute_score(entry.freq, a.1);

        local.push(e);
        local.push(s);
        local.push(a);

        let _svx = svx_evaluate(&local);
        let collapse = dqi_collapse(&local, &memory);

        println!(
            "window={} decision={} entropy={} symmetry={} grammar={} memory_streak={}",
            i, collapse.selected, entropy_val, symmetry_val, grammar_val, memory.anomaly_streak
        );

        memory.update(&collapse.selected);
        decisions.push((collapse.selected, collapse.anomaly_score));
    }

    println!("====================================");

    println!("CLUSTER COMPETITION");

    let ranked = rank_clusters(&cluster_scores);

    for (i, (sig, score)) in ranked.iter().enumerate() {
        println!(
            "RANK {} → cluster={} freq={} strength={:.2}",
            i + 1,
            sig,
            score.freq,
            score.strength
        );
    }

    println!("====================================");

    let global = dqi_collapse(&decisions, &memory);

    let current_freq = prev_freq + 4;
    let current_runs = prev_runs + 1;

    let trend = classify_trend(prev_freq, current_freq);
    let lifecycle = classify_lifecycle(current_runs);
    let proximity = dominance_proximity(current_runs);
    let dominant = is_dominant(&lifecycle, &trend);

    println!("GLOBAL COLLAPSE: {}", global.selected);
    println!("RATIONALE: {}", global.rationale);
    println!("TREND: {}", trend);
    println!("LIFECYCLE: {}", lifecycle);
    println!("PROXIMITY: {}", proximity);
    println!("DOMINANT: {}", dominant);

    if dominant {
        println!("DRE_TRIGGER: ENFORCE_SIGNAL");
    }

    println!("====================================");
    println!("CDS COMPLETE");
}
