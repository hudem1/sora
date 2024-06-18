use starknet::ContractAddress;
use super::case::Vec2;

#[derive(Drop, Serde)]
#[dojo::model]
struct Path {
    #[key]
    player: ContractAddress,
    cases: Option<Array<Vec2>>,
    end_time: Option<u32>
}