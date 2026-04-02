use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CdsConfig {
    pub dataset_path: String,
    pub chunk_size: usize,
    pub window_size: usize,
    pub overlap: usize,
    pub checkpoint_every_windows: usize,
    pub proof_dir: String,
    pub state_dir: String,
    pub collapse_dir: String,
    pub runtime_dir: String,
}

impl Default for CdsConfig {
    fn default() -> Self {
        Self {
            dataset_path: "/data/data/com.termux/files/home/repos/odin_os/artifacts/runtime/cds_input.txt".to_string(),
            chunk_size: 64,
            window_size: 128,
            overlap: 32,
            checkpoint_every_windows: 10,
            proof_dir: "/data/data/com.termux/files/home/repos/odin_os/artifacts/curie_deterministic_stream/proofs".to_string(),
            state_dir: "/data/data/com.termux/files/home/repos/odin_os/artifacts/curie_deterministic_stream/state".to_string(),
            collapse_dir: "/data/data/com.termux/files/home/repos/odin_os/artifacts/curie_deterministic_stream/collapse".to_string(),
            runtime_dir: "/data/data/com.termux/files/home/repos/odin_os/artifacts/curie_deterministic_stream/runtime".to_string(),
        }
    }
}
