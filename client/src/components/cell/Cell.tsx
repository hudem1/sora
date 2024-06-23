import { useDojo } from '../../dojo/useDojo';
import { useComponentValue } from '@dojoengine/react';
import { getEntityIdFromKeys } from '@dojoengine/utils';
import './Cell.css';
import { useMemo } from 'react';
import { strToNature, TileNature } from '../../utils';

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
  // console.log('--- tile: x: ' + x + ' y: ' + y + ': ---');
  // console.log(tile);

  const bgColor = useMemo(() => {
    console.log('--- tile: x: ' + x + ' y: ' + y + ': ---');
    console.log(tile?.nature);
    switch (strToNature(tile?.nature as unknown as string)) {
      case TileNature.Grass:
        return 'green';
      case TileNature.Water:
        return 'blue';
      case TileNature.Tree:
        return 'green';
      case TileNature.Road:
        return 'AntiqueWhite';
      case TileNature.House:
        return 'brown';
    }
  }, [tile]);

  return (
    <div className="grid-cell" style={{ backgroundColor: bgColor }}>
      {tile?.allocated == 'Some' ? 'X' : '.'}
    </div>
  );
};

export default Cell;