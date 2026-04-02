use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WindowRecord {
    pub window_id: String,
    pub start_offset: usize,
    pub end_offset: usize,
    pub values: Vec<String>,
}

pub struct WindowEngine {
    buffer: Vec<String>,
    pub window_size: usize,
    pub overlap: usize,
    pub next_window_index: usize,
    pub next_window_start_offset: usize,
}

impl WindowEngine {
    pub fn new(window_size: usize, overlap: usize) -> Self {
        Self {
            buffer: Vec::new(),
            window_size,
            overlap,
            next_window_index: 0,
            next_window_start_offset: 0,
        }
    }

    pub fn push_chunk(&mut self, chunk: Vec<String>) -> Vec<WindowRecord> {
        self.buffer.extend(chunk);
        let mut windows = Vec::new();

        while self.buffer.len() >= self.window_size {
            let values = self.buffer[..self.window_size].to_vec();
            let start = self.next_window_start_offset;
            let end = start + self.window_size.saturating_sub(1);

            let record = WindowRecord {
                window_id: format!("CDS_WINDOW_{:08}", self.next_window_index),
                start_offset: start,
                end_offset: end,
                values,
            };
            windows.push(record);

            let stride = self.window_size.saturating_sub(self.overlap);
            self.buffer.drain(0..stride);
            self.next_window_index += 1;
            self.next_window_start_offset += stride;
        }

        windows
    }
}
