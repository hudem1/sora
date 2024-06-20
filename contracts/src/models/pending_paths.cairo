use starknet::ContractAddress;
use super::tile::Vec2;

const WORLD_PENDING_PATHS_ID: u32 = 999;

#[derive(Drop, Serde)]
#[dojo::model]
struct WorldPendingPaths {
    #[key]
    paths_id: u32,
    pending_paths: Array<ContractAddress>,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct PendingPath {
    #[key]
    player: ContractAddress,
    path: Option<Span<Vec2>>, // Option or directly span ?
}
