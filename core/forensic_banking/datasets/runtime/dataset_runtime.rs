use crate::core::forensic_banking::datasets::contracts::{DatasetRequest, DatasetResult};
use crate::core::forensic_banking::datasets::parsers::CsvParser;

pub struct DatasetRuntime;

impl DatasetRuntime {

    pub fn load_dataset(request: DatasetRequest) -> DatasetResult {

        println!("Loading dataset: {}", request.dataset_path);

        let records = CsvParser::parse(&request.dataset_path);

        DatasetResult {
            dataset_id: request.dataset_id,
            records_loaded: records,
            status: "dataset_loaded".to_string(),
        }
    }
}
