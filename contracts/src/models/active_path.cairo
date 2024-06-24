use starknet::ContractAddress;
use super::tile::Vec2;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct ActivePath {
    #[key]
    player: ContractAddress,
    // tiles: Option<Span<Vec2>>,
    tiles: Span<u32>,
    // end_time: Option<u64>
    end_time: u64,
    completed: bool,
}
