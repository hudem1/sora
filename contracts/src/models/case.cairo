use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Introspect)]
#[dojo::model]
struct Case {
    #[key]
    coords: Vec2,
    nature: CaseNature,
    allocated: Option<ContractAddress> // whether an agent is already present on the case
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Vec2 {
    x: u32,
    y: u32
}

#[derive(Copy, Drop, Serde, Introspect)]
enum CaseNature {
    Road,
    House,
    Tree,
    Water
}

