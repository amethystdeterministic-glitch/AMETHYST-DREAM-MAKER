use std::collections::HashSet;

pub fn signature_similarity(sig1: &str, sig2: &str) -> f64 {
    let set1: HashSet<&str> = sig1.split('|').collect();
    let set2: HashSet<&str> = sig2.split('|').collect();

    let intersection = set1.intersection(&set2).count() as f64;
    let union = set1.union(&set2).count() as f64;

    if union == 0.0 {
        return 0.0;
    }

    intersection / union
}
