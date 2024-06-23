#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    // import test utils
    use dojo_starter::{
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{
            position::{Position, position},
            moves::{Moves, Direction, DirectionsAvailable, moves},
            tile::{Tile, Vec2, TileNature, tile},
            path::{Path, path},
            // pending_paths::{PendingPaths, WorldPendingPaths, pending_paths},
            world_settings::{WorldSettings, world_settings},
        },
    };

    fn deploy() -> (
        IWorldDispatcher,
        IActionsDispatcher,
        starknet::ContractAddress,
    ) {
        let _caller = starknet::contract_address_const::<0x0>();
        let mut models = array![
            position::TEST_CLASS_HASH,
            moves::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            path::TEST_CLASS_HASH,
            // pending_paths::TEST_CLASS_HASH,
            world_settings::TEST_CLASS_HASH
        ];
        let world = spawn_test_world(models);
        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let actions_system = IActionsDispatcher { contract_address };
        (
            world,
            actions_system,
            contract_address,
        )
    }

    fn setup() -> (
        IWorldDispatcher,
        IActionsDispatcher,
        starknet::ContractAddress,
        u32,
    ) {
        let (world, actions_system, contract_address) = deploy();

        let grid_size = 4;
        let grid_nature = array![
            TileNature::Grass, TileNature::House, TileNature::Water, TileNature::Water,
            TileNature::Grass, TileNature::Road, TileNature::Water, TileNature::Water,
            TileNature::Grass, TileNature::Road, TileNature::Road, TileNature::Road,
            TileNature::Grass, TileNature::Road, TileNature::Grass, TileNature::Grass,
        ];

        actions_system.init_grid(grid_size, grid_nature.span());

        (
            world,
            actions_system,
            contract_address,
            grid_size,
        )
    }

    #[test]
    fn test_deploy() {
        deploy();
    }

    #[test]
    fn test_init_grid() {
        setup();
    }

        // call move with direction right
        // actions_system.move(Direction::Right);

        // Check world state
        // let moves = get!(world, caller, Moves);

        // casting right direction
        // let right_dir_felt: felt252 = Direction::Right.into();

        // check last direction
        // assert(moves.last_direction.into() == right_dir_felt, 'last direction is wrong');

        // get new_position
        // let new_position = get!(world, caller, Position);

        // check new position x
        // assert(new_position.vec.x == 11, 'position x is wrong');

        // check new position y
        // assert(new_position.vec.y == 10, 'position y is wrong');
    // }
}
