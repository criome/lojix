use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct CoreKeys {
    pub left: HandKeys,
    pub right: HandKeys,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct HandKeys {
    pub upper: HandKeyRow,
    pub mid: HandKeyRow,
    pub lower: HandKeyRow,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct HandKeyRow {
    pub mars: KeyboardKey,
    pub jupiter: KeyboardKey,
    pub saturn: KeyboardKey,
    pub venus: KeyboardKey,
    pub mercury: KeyboardKey,
}

#[derive(Serialize, Deserialize, Debug)]
pub enum Style {
    Coleremak
}

impl Style {
    fn to_helix_keymap(&Self) -> Keymap {
	
    }
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Keymap {
    normal: NormalKeymap,
    insert: InsertKeymap,
}
