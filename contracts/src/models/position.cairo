use starknet::ContractAddress;
use super::tile::Vec2;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Position {
    #[key]
    player: ContractAddress,
    vec: Vec2,
}
