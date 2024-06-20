import { useDojo } from '../../dojo/useDojo';
import { useComponentValue } from '@dojoengine/react';
import { getEntityIdFromKeys } from '@dojoengine/utils';
import './Cell.css';

interface CellProps {
  x: number;
  y: number;
}

const Cell = ({x, y}: CellProps) => {
  const {
    setup: { clientComponents: { Tile }, },
    account,
  } = useDojo();

  const entityId = getEntityIdFromKeys([
    BigInt(x), BigInt(y),
  ]);

  const tile = useComponentValue(Tile, entityId);
  console.log('--- tile: x: ' + x + ' y: ' + y + ': ---');
  console.log(tile);

  return (
    <div className="grid-cell">
      0
    </div>
  );
};

export default Cell;