import { useDojo } from '../../dojo/useDojo';
import { useComponentValue } from '@dojoengine/react';
import { getEntityIdFromKeys } from '@dojoengine/utils';
import './Cell.css';
import { useMemo } from 'react';

interface CellProps {
  x: number;
  y: number;
}

enum CaseNature {
  Road = 'Road',
  House = 'House',
  Tree = 'Tree',
  Water = 'Water',
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
    switch (tile?.nature) {
      case CaseNature.Road:
        return 'AntiqueWhite';
      case CaseNature.House:
        return 'brown';
      case CaseNature.Tree:
        return 'green';
      case CaseNature.Water:
        return 'blue';
    }
  }, [tile]);

  return (
    <div className="grid-cell" style={{ backgroundColor: bgColor }}>
      {tile?.allocated == 'Some' ? 'X' : '.'}
    </div>
  );
};

export default Cell;