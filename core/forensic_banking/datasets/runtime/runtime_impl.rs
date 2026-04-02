#[derive(Debug, Clone)]
pub struct DatasetRecord {
    pub dataset_id: String,
    pub rows: usize,
}

pub struct DatasetRegistry;

impl DatasetRegistry {

    pub fn register(dataset_id: &str, rows: usize) -> DatasetRecord {

        println!("Registering dataset {}", dataset_id);

        DatasetRecord {
            dataset_id: dataset_id.to_string(),
            rows,
        }
    }

}
