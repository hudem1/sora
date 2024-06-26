use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::Position;
use dojo_starter::models::tile::Vec2;
use dojo::world::IWorldDispatcher;
use dojo_starter::models::tile::TileNature;

// define the interface
#[dojo::interface]
trait IActions {
    fn init_grid(ref world: IWorldDispatcher, grid_size: u32, map: Span<TileNature>);
    fn spawn(ref world: IWorldDispatcher);
    // fn test_set_tile_alloc(ref world: IWorldDispatcher);
    // fn test_set_tile_unalloc(ref world: IWorldDispatcher);
    fn move(ref world: IWorldDispatcher, direction: Direction);
    fn verify_path(ref world: IWorldDispatcher, path: Array<Vec2>);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, is_move_inside_grid_bounds, next_position};
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use dojo_starter::models::{
        position::{Position}, moves::{Moves, Direction, DirectionsAvailable},
        world_settings::{WorldSettings, SETTINGS_ID}, tile::{Tile, Vec2, TileNature},
        path::Path, pending_paths::{WorldPendingPaths, WORLD_PENDING_PATHS_ID, PendingPath},
    };
    use core::array::ArrayTrait;

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
        fn init_grid(ref world: IWorldDispatcher, grid_size: u32, map: Span<TileNature>) {
            assert(grid_size > 0, 'grid size must be > 0');
            assert(map.len() == grid_size * grid_size, 'map size must match grid size');

            set!(world, (WorldSettings { settings_id: SETTINGS_ID, grid_size, map }));

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
                            nature: *map.at(row * grid_size + col),
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

        fn move(ref world: IWorldDispatcher, direction: Direction) {
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
        }

        fn verify_path(ref world: IWorldDispatcher, mut path: Array<Vec2>) {
            let player = get_caller_address();
            let path_span = path.span();

            let mut is_path_free = true;
            while let Option::Some(coords) = path.pop_front() {
                let tile = get!(world, (coords.x, coords.y), (Tile));
                if tile.allocated.is_some() {
                    is_path_free = false;
                    break;
                }
            };

            if is_path_free {
                // move at a speed of 1 tile every second
                let end_time = get_block_timestamp() + path_span.len().into() * 1000;
                set!(world, (
                    Path {
                        player,
                        tiles: Option::Some(path_span),
                        end_time: Option::Some(end_time)
                    }
                ));
            } else {
               set!(world, (PendingPath {
                    player,
                    path: Option::Some(path_span)
                }));

                let mut world_pending_paths = get!(world, WORLD_PENDING_PATHS_ID, (WorldPendingPaths));
                world_pending_paths.pending_paths.append(player);

                set!(world, (world_pending_paths));
            }
        }
    }
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
