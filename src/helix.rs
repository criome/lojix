use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct CoreKeys {
    pub top_left: CoreKeyRow,
    pub top_right: CoreKeyRow,
    pub mid_left: CoreKeyRow,
    pub mid_right: CoreKeyRow,
    pub bottom_left: CoreKeyRow,
    pub bottom_right: CoreKeyRow,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct CoreKeyRow {
    pub mars: Key,
    pub jupiter: Key,
    pub saturn: Key,
    pub venus: Key,
    pub mercury: Key,
}
