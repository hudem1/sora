use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Tile {
    #[key]
    _coords: Vec2,
    coords: Vec2,
    nature: CaseNature,
    allocated: Option<ContractAddress>, // whether an agent is already present on the case
}

#[derive(Copy, Drop, Serde, PartialEq, Debug, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}

#[generate_trait]
impl Vec2IntoU32Impl of Vec2IntoU32 {
    fn into_u32(self: Vec2, grid_size: u32) -> u32 {
        self.y * grid_size + self.x
    }
}

#[derive(Copy, Drop, Serde, Introspect)]
enum CaseNature {
    Road,
    House,
    Tree,
    Water
}
