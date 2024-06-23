import { useDojo } from "../../dojo/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useMemo } from "react";
import { strToNature, TileNature } from "../../utils";
// Tilemaps
import grass_map from "../../assets/tiles/Grass.png";
import trees_map from "../../assets/tiles/Trees.png";
import houses_map from "../../assets/tiles/Houses.png";
import agent_map from "../../assets/tiles/Agent.png";
import "./Cell.css";

interface CellProps {
  x: number;
  y: number;
}

const zoom = 4;
const Cell = ({ x, y }: CellProps) => {
  const {
    setup: {
      clientComponents: { Tile },
    },
    account,
  } = useDojo();

  const entityId = getEntityIdFromKeys([BigInt(x), BigInt(y)]);

  const tile = useComponentValue(Tile, entityId);

  const [
    file,
    x_index,
    y_index,
    overlay_file,
    overlay_x_index,
    overlay_y_index,
  ] = useMemo(() => {
    switch (strToNature(tile?.nature as unknown as string)) {
      case TileNature.Grass:
        return [grass_map, 1, 0, null, 0, 0];
      case TileNature.Water:
        return [grass_map, 0, 0, null, 0, 0];
      case TileNature.Tree:
        return [grass_map, 1, 0, trees_map, Math.floor(Math.random() * 4), 0];
      case TileNature.Road:
        return [grass_map, 3 + Math.floor(Math.random() * 2), 0, null, 0, 0];
      case TileNature.House:
        return [
          grass_map,
          1,
          0,
          houses_map,
          Math.floor(Math.random() * 3),
          Math.floor(Math.random() * 4),
        ];
    }
  }, [tile]);

  return (
    <div
      style={{
        width: `${16 * zoom}px`,
        height: `${16 * zoom}px`,
      }}
    >
      <div
        className="grid-cell"
        style={{
          transform: `scale(${zoom})`,
          backgroundImage: `url(${file})`,
          backgroundPosition: `-${x_index * 16}px -${y_index * 16}px`,
          boxSizing: "border-box",
          border: "0.5px solid goldenrod",
        }}
      >
        {overlay_file && (
          <div
            className="grid-cell"
            style={{
              backgroundImage: `url(${overlay_file})`,
              backgroundPosition: `-${overlay_x_index! * 16}px -${overlay_y_index! * 16}px`,
              transform: "scale(0.7)",
              transformOrigin: "center",
            }}
          ></div>
        )}
        {tile?.allocated == "Some" ? (
          <div
            className="grid-cell"
            style={{
              backgroundImage: `url(${agent_map})`,
              transform: "scale(0.7)",
              transformOrigin: "center",
            }}
          ></div>
        ) : (
          ""
        )}
      </div>
    </div>
  );
};

export default Cell;
