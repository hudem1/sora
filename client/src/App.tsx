import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import "./App.css";
import { TileNature } from "./utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "./dojo/useDojo";
import Grid from "./components/grid/Grid";

const WORLD_SETTINGS_ID = 999;
const worldEntityId = getEntityIdFromKeys([BigInt(WORLD_SETTINGS_ID)]);

const init_settings = {
  grid_size: 2,
  map: [1, 2, 3, 4] as TileNature[],
};

function App() {
  const {
    setup: {
      systemCalls: { spawn, move, init_grid },
      clientComponents: { WorldSettings },
    },
    account,
  } = useDojo();

  // entity id we are syncing
  const entityId = getEntityIdFromKeys([
    BigInt(account?.account.address),
  ]) as Entity;

  // get current component values
  // const position = useComponentValue(Position, entityId);
  // const directions = useComponentValue(DirectionsAvailable, entityId);

  const grid_size = useComponentValue(WorldSettings, worldEntityId)?.grid_size;
  console.log("grid_size---");
  console.log(grid_size);

  // console.log(moves);

  return (
    <div className="App">
      <button
        onClick={() =>
          init_grid(account.account, init_settings.grid_size, init_settings.map)
        }
      >
        Init grid
      </button>
      <button onClick={() => spawn(account.account)}>Spawn</button>
      <h1>Game Grid</h1>
      {grid_size && <Grid rows={grid_size} cols={grid_size} />}
    </div>
  );
}

export default App;
