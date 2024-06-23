const SETTINGS_ID: u32 = 999;
use super::tile::TileNature;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct WorldSettings {
    #[key]
    settings_id: u32,
    grid_size: u32,
    map: Span<TileNature>
}
