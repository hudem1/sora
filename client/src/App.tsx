import { useComponentValue } from "@dojoengine/react";
import { Entity, getComponentValue } from "@dojoengine/recs";
import { useCallback, useState } from "react";
import "./App.css";
import { Direction, Vec2 } from "./utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "./dojo/useDojo";
import Grid from "./components/grid/Grid";

const WORLD_SETTINGS_ID = 999;
const worldEntityId = getEntityIdFromKeys([BigInt(WORLD_SETTINGS_ID)]);

const computeDirectionFromPosition = (current_pos: number, next_pos: number, grid_size: number): Direction => {
    switch (next_pos) {
        case current_pos + grid_size:
            return Direction.Down;
        case current_pos - grid_size:
            return Direction.Up;
        case current_pos + 1:
            return Direction.Right;
        case current_pos - 1:
            return Direction.Left;
        default:
            throw new Error('Next position is not next to current position');
    }
}

/**
 * TO DO list:
 * - be able to select path
 * - prevent from registering path if one is already active OR pending
 * - highlight path tiles
 */

export interface ActivePath {
    path: Map<number, boolean>;
    endTime: number;
}

function App() {
    const {
        setup: {
            systemCalls: { spawn, move, init_grid, verifyPath },
            clientComponents: { Path, Position, WorldSettings },
            dojoProvider,
        },
        account,
    } = useDojo();

    const [activePath, setActivePath] = useState<ActivePath>({
        path: new Map(),
        endTime: 0
    });

    // entity id we are syncing
    const addressEntityId = getEntityIdFromKeys([
        BigInt(account?.account.address),
    ]) as Entity;


    // get current component values
    // const position = useComponentValue(Position, entityId);
    // const directions = useComponentValue(DirectionsAvailable, entityId);

    const grid_size = useComponentValue(WorldSettings, worldEntityId)?.grid_size;
    console.log('grid_size---');
    console.log(grid_size);

    const coordsIntoTileId = useCallback(
        (x: number, y: number) => y * grid_size! + x,
        [grid_size]
    );

    const moveAlongRegisteredPath = useCallback(async (path: string[]) => {
        console.log('--- dans moveAlongRegisteredPath ---');
        for (const i in path) {
            if (+i == 0) continue;
            await move(account.account, computeDirectionFromPosition(+path[+i-1], +path[i], grid_size!));
        }
    }, [account.account, grid_size, move]);

    const setActivePlayerPath = useCallback((path: string[], endTime: number) => {
        setActivePath({
            path:  new Map(path.map((tileId) => [+tileId, true])),
            endTime,
        });
    }, []);

    const registerPath = useCallback(async () => {
        // const path: Vec2[] = [
        //     { x: 2, y: 1 },
        //     { x: 2, y: 2 },
        //     { x: 2, y: 3 },
        //     { x: 3, y: 3 },
        //     { x: 4, y: 3 },
        //     { x: 4, y: 4 },
        //     { x: 4, y: 5 },
        //     { x: 4, y: 6 },
        //     { x: 5, y: 6 },
        //     { x: 6, y: 6 },
        //     { x: 6, y: 7 },
        //     { x: 7, y: 7 },
        // ];

        const path: number[] = [
            coordsIntoTileId(2, 1),
            coordsIntoTileId(2, 2),
            coordsIntoTileId(2, 3),
            coordsIntoTileId(3, 3),
            coordsIntoTileId(4, 3),
            coordsIntoTileId(4, 4),
            coordsIntoTileId(4, 5),
            coordsIntoTileId(4, 6),
            coordsIntoTileId(5, 6),
            coordsIntoTileId(6, 6),
            coordsIntoTileId(6, 7),
            coordsIntoTileId(7, 7),
        ];

        try {
            await verifyPath(account.account, path);
        } catch (error) {
            // TODO: show banner
            return;
        }

        const entity = getEntityIdFromKeys([
            BigInt(account.account.address)
          ]);
        const player_path = getComponentValue(Path, entity);

        console.log('--- player_path ---');
        console.log(player_path);

        const current_block_timestamp = (await dojoProvider.provider.getBlock()).timestamp;
        // const id = (await dojoProvider.provider.getBlockLatestAccepted()).block_number;
        // const current_block_timestamp = (await dojoProvider.provider.getBlockWithTxHashes(id)).timestamp
        console.log('timestamp: ', current_block_timestamp);
        console.log('end time: ', player_path?.end_time);
        if (player_path?.end_time ?? 0 > current_block_timestamp) {
            setActivePlayerPath(player_path?.tiles!, player_path?.end_time!)
            await moveAlongRegisteredPath(player_path?.tiles ?? []);
        } else {
            // error should not occur as path has been accepted and set as active for the player
            console.error("Player's path is already expired");
        }
    }, [account.account, verifyPath, Path, coordsIntoTileId, dojoProvider.provider, moveAlongRegisteredPath, setActivePlayerPath]);

    return (
        <div className="App">
            <button onClick={() => init_grid(account.account, 10)}>Init grid</button>
            <button onClick={() => spawn(account.account)}>Spawn</button>
            <button onClick={registerPath}>Verify path</button>
            <h1>Game Grid</h1>
            {grid_size && <Grid rows={grid_size} cols={grid_size} activePath={activePath} />}
      </div>
    );
}

export default App;