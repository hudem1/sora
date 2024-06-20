use starknet::ContractAddress;
use super::tile::Vec2;

#[derive(Drop, Serde)]
#[dojo::model]
struct Path {
    #[key]
    player: ContractAddress,
    tiles: Option<Span<Vec2>>,
    end_time: Option<u64>
}
