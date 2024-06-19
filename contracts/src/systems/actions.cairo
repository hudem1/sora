use dojo_starter::models::moves::Direction;
use dojo_starter::models::position::Position;

// define the interface
#[dojo::interface]
trait IActions {
    fn init_grid(ref world: IWorldDispatcher, grid_size: u32);
    fn spawn(ref world: IWorldDispatcher);
    fn move(ref world: IWorldDispatcher, direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, is_move_inside_grid_bounds, next_position};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{
        position::{Position}, moves::{Moves, Direction, DirectionsAvailable}, world_settings::{WorldSettings, SETTINGS_ID}, tile::{Tile, Vec2, CaseNature}
    };

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

            let mut row_i = 0;
            while row_i < grid_size {
                let mut col = 0;
                while col < grid_size {
                    set!(
                        world,
                        (
                            Tile {
                                // not stored, only used for computing storage address
                                _coords: Vec2 { x: row_i, y: col },
                                coords: Vec2 { x: row_i, y: col },
                                nature: CaseNature::Road,
                                allocated: Option::None,
                            }
                        )
                    );
                    col += 1;
                };

                row_i += 1;
            };
        }

        fn spawn(ref world: IWorldDispatcher) {
            let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
            assert(world_settings.grid_size > 0, 'must first initialize grid');

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Set the player's position at the center of the grid
            // Set available directions to all four directions.

            let directions_available = DirectionsAvailable {
                player,
                directions: array![
                    Direction::Up, Direction::Right, Direction::Down, Direction::Left
                ],
            };

            set!(
                world,
                (
                    Moves {
                        player, last_direction: Direction::None(()), can_move: true
                    },
                    Position {
                        player, vec: Vec2 { x: world_settings.grid_size / 2, y: world_settings.grid_size / 2 }
                    },
                    directions_available
                )
            );
        }

        fn move(ref world: IWorldDispatcher, direction: Direction) {
            let world_settings: WorldSettings = get!(world, SETTINGS_ID, (WorldSettings));
            assert(world_settings.grid_size > 0, 'must first initialize grid');

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            // Calculate the player's next position based on the provided direction.
            assert(
                is_move_inside_grid_bounds(position, direction, world_settings.grid_size),
                'illegal move: out of bounds'
            );
            let next = next_position(position, direction);

            // Update the world state with the new moves data and position.
            set!(world, (moves, next));
            // Emit an event to the world to notify about the player's move.
            emit!(world, (Moved { player, direction }));
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
        Direction::Right => { position.vec.x < grid_size },
        Direction::Up => { position.vec.y < grid_size },
        Direction::Down => { position.vec.y > 0 },
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
