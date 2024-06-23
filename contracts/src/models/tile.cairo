use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Tile {
    #[key]
    _coords: Vec2,
    coords: Vec2,
    nature: TileNature,
    allocated: Option<ContractAddress>, // whether an agent is already present on the case
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}

#[derive(Copy, Drop, Serde, Introspect)]
enum TileNature {
    Grass,
    Water,
    Tree,
    Road,
    House,
}
