use core::array::ArrayTrait;
use super::case::{Case, Vec2, CaseNature};

#[derive(Drop, Serde)]
#[dojo::model]
struct Grid {
    #[key]
    simulation_id: u32,
    grid: Array<Array<Case>>
}

#[generate_trait]
impl GridImpl of GridTrait {
    fn new(simulation_id: u32, size: u32) -> Grid {
        let mut grid: Array<Array<Case>> = array![];

        let mut row_i = 0;
        while row_i < size {
            // build grid row
            let mut row: Array<Case> = array![];

            let mut col = 0;
            while col < size {
                row.append(Case {
                    coords: Vec2 { x: row_i, y: col },
                    nature: CaseNature::Road,
                    allocated: Option::None,
                })
            };

            // add row to grid
            grid.append(row);
        };

        Grid {
            simulation_id,
            grid,
        }
    }
}