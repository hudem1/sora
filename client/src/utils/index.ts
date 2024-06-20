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
