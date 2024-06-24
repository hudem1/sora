use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::Position;
use dojo_starter::models::tile::Vec2;
use dojo::world::IWorldDispatcher;

// define the interface
#[dojo::interface]
trait IActions {
    fn init_grid(ref world: IWorldDispatcher, grid_size: u32);
    fn spawn(ref world: IWorldDispatcher);
    // fn test_set_tile_alloc(ref world: IWorldDispatcher);
    // fn test_set_tile_unalloc(ref world: IWorldDispatcher);
    fn move_freely(ref world: IWorldDispatcher, direction: Direction);
    fn move_on_path(ref world: IWorldDispatcher, direction: Direction);
    fn verify_path(ref world: IWorldDispatcher, path: Array<u32>) -> bool;
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, is_move_inside_grid_bounds, next_position};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo_starter::models::{
        position::{Position}, moves::{Moves, Direction, DirectionsAvailable},
        world_settings::{WorldSettings, SETTINGS_ID}, tile::{Tile, Vec2, CaseNature, Vec2IntoU32},
        active_path::ActivePath, pending_paths::{WorldPendingPaths, WORLD_PENDING_PATHS_ID, PendingPath},
    };
    use core::array::ArrayTrait;
    use core::array::SpanTrait;

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Moved {
        #[key]
        player: ContractAddress,
        direction: Direction,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn init_grid(ref world: IWorldDispatcher, grid_size: u32) {
            assert(grid_size > 0, 'grid size must be > 0');

            set!(world, (WorldSettings { settings_id: SETTINGS_ID, grid_size }));

            let mut row = 0;
            while row < grid_size {
                let mut col = 0;
                while col < grid_size {
                    set!(
                        world,
                        (Tile {
                            // not stored, only used for computing storage address
                            _coords: Vec2 { y: row, x: col },
                            coords: Vec2 { y: row, x: col },
                            nature: CaseNature::Road,
                            allocated: Option::None,
                        })
                    );
                    col += 1;
                };

                row += 1;
            };
        }

        fn spawn(ref world: IWorldDispatcher) {
            let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
            assert(world_settings.grid_size > 0, 'must first initialize grid');

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            let spawn_pos = Vec2 {
                x: world_settings.grid_size / 2, y: world_settings.grid_size / 2
            };

            let mut tile = get!(world, (world_settings.grid_size / 2, world_settings.grid_size / 2), (Tile));
            tile.allocated = Option::Some(player);

            set!(
                world,
                (
                    Moves { player, last_direction: Direction::None(()), can_move: true },
                    Position { player, vec: spawn_pos },
                    DirectionsAvailable {
                        player,
                        directions: array![
                            Direction::Up, Direction::Right, Direction::Down, Direction::Left
                        ],
                    },
                    tile,
                )
            );
        }

        // fn test_set_tile_alloc(ref world: IWorldDispatcher) {
        //     let player = get_caller_address();

        //     let player_felt252: felt252 = player.into();
        //     println!("--- player in alloc: {player_felt252}");

        //     let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
        //     let mut tile = get!(world, (world_settings.grid_size / 2, world_settings.grid_size / 2), (Tile));
        //     tile.allocated = Option::Some(player);
        //     set!(world, (tile));
        // }

        // fn test_set_tile_unalloc(ref world: IWorldDispatcher) {
        //     let player = get_caller_address();

        //     let player_felt252: felt252 = player.into();
        //     println!("--- player in unalloc: {player_felt252}");

        //     let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
        //     let mut tile = get!(world, (world_settings.grid_size / 2, world_settings.grid_size / 2), (Tile));
        //     tile.allocated = Option::None;
        //     set!(world, (tile));
        // }

        fn move_freely(ref world: IWorldDispatcher, direction: Direction) {
            InternalActionsImpl::move(world, direction);
        }

        fn move_on_path(ref world: IWorldDispatcher, direction: Direction) {
            let grid_size = get!(world, SETTINGS_ID, (WorldSettings)).grid_size;
            let player = get_caller_address();

            let next_pos: Vec2 = InternalActionsImpl::move(world, direction);

            let mut path = get!(world, (player), (ActivePath));
            let last_pos = *path.tiles.at(path.tiles.len() - 1);
            if next_pos.into_u32(grid_size) == last_pos {
                path.completed = true;
                set!(world, (path));
            }
        }

        fn verify_path(ref world: IWorldDispatcher, mut path: Array<u32>) -> bool {
            let grid_size = get!(world, SETTINGS_ID, (WorldSettings)).grid_size;

            let player = get_caller_address();
            let path_span = path.span();
            // let path_span = path.clone();

            assert(path.len() > 1, 'Path must be at least 2 tiles');
            // let first_pos = *path.get(0).unwrap().unbox();
            let tile_id = path.pop_front().unwrap();
            let player_pos = get!(world, player, (Position));
            // println!("first_pos: {:?}", first_pos);
            // println!("player_pos: {:?}", player_pos.vec);
            assert(tile_id == player_pos.vec.into_u32(grid_size), 'Path start position is wrong');

            let mut is_path_free = true;
            while let Option::Some(current_tile) = path.pop_front() {
                let y = current_tile / grid_size;
                let x = current_tile % grid_size;
                assert(x < grid_size && y < grid_size, 'Path tile out of bounds');

                let tile = get!(world, (x, y), (Tile));
                if tile.allocated.is_some() {
                    is_path_free = false;
                    break;
                }
            };

            // println!("--- is_path_free: {}", is_path_free);
            if is_path_free {
                // move at a speed of 1 tile every second
                let end_time = get_block_timestamp() + path_span.len().into() * 1000;
                set!(world, (
                    ActivePath {
                        player,
                        // tiles: Option::Some(path_span),
                        tiles: path_span,
                        // end_time: Option::Some(end_time)
                        end_time: end_time,
                        completed: false,
                    }
                ));
            } else {
            //    set!(world, (PendingPath {
            //         player,
            //         path: Option::Some(path_span)
            //     }));

            //     let mut world_pending_paths = get!(world, WORLD_PENDING_PATHS_ID, (WorldPendingPaths));
            //     world_pending_paths.pending_paths.append(player);

            //     set!(world, (world_pending_paths));
            }

            is_path_free
        }
    }

    #[generate_trait]
    impl InternalActionsImpl of InternalActionsTrait {
        fn move(world: IWorldDispatcher, direction: Direction) -> Vec2 {
            let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
            assert(world_settings.grid_size > 0, 'must first initialize grid');

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));
            let mut tile = get!(world, (position.vec.x, position.vec.y), (Tile));

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            assert(
                is_move_inside_grid_bounds(position, direction, world_settings.grid_size),
                'illegal move: out of bounds'
            );

            // Calculate the player's next position based on the provided direction.
            let next_pos: Position = next_position(position, direction);

            let mut next_tile = get!(world, (next_pos.vec.x, next_pos.vec.y), (Tile));
            assert(
                next_tile.allocated.is_none(),
                'illegal move: tile is allocated'
            );

            tile.allocated = Option::None;
            next_tile.allocated = Option::Some(player);

            // Update the world state with the new moves, position and tile data
            set!(world, (moves, next_pos, tile, next_tile));
            // Emit an event to the world to notify about the player's move.
            emit!(world, (Moved { player, direction }));

            next_pos.vec
        }
    }
// #[generate_trait]
// impl ActionsInternImpl of ActionsIntern {
//     fn is_move_inside_grid_bounds(position: Position, direction: Direction, grid_size: u32) -> bool {
//         match direction {
//             Direction::Left => { position.vec.x > 0 },
//             Direction::Right => { position.vec.x < grid_size },
//             Direction::Up => { position.vec.y < grid_size },
//             Direction::Down => { position.vec.y > 0 },
//             Direction::None => { true },
//         }
//     }
// }
}


fn is_move_inside_grid_bounds(position: Position, direction: Direction, grid_size: u32) -> bool {
    match direction {
        Direction::Left => { position.vec.x > 0 },
        Direction::Right => { position.vec.x < grid_size - 1 },
        Direction::Up => { position.vec.y > 0 },
        Direction::Down => { position.vec.y < grid_size - 1 },
        Direction::None => { true },
    }
}

fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None => { return position; },
        Direction::Left => { position.vec.x -= 1; },
        Direction::Right => { position.vec.x += 1; },
        Direction::Up => { position.vec.y -= 1; },
        Direction::Down => { position.vec.y += 1; },
    };

    position
}
