export enum Direction {
    Left = 1,
    Right = 2,
    Up = 3,
    Down = 4,
}

export function updatePositionWithDirection(
    direction: Direction,
    value: { vec: { x: number; y: number } }
) {
    const new_value = { vec: { ...value.vec } };

    switch (direction) {
        case Direction.Left:
            new_value.vec.x--;
            break;
        case Direction.Right:
            new_value.vec.x++;
            break;
        case Direction.Up:
            new_value.vec.y--;
            break;
        case Direction.Down:
            new_value.vec.y++;
            break;
        default:
            throw new Error("Invalid direction provided");
    }

    return new_value;
}

export enum TileNature {
   Grass = 1,
   Water = 2,
   Tree = 3,
   Road = 4,
   House = 5,
}

export const strToNature = (str: string): TileNature => {
    switch (str) {
        case 'Grass':
            return TileNature.Grass;
        case 'Water':
            return TileNature.Water;
        case 'Tree':
            return TileNature.Tree;
        case 'Road':
            return TileNature.Road;
        case 'House':
            return TileNature.House;
        default:
            throw new Error('Invalid tile nature');
    }
}