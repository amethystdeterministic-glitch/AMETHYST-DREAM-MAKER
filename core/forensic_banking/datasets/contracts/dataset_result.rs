#[derive(Debug, Clone)]
pub struct DatasetResult {
    pub dataset_id: String,
    pub records_loaded: usize,
    pub status: String,
}
