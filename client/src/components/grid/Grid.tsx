import React, { useEffect } from 'react';
import './Grid.css';
import Cell from '../cell/Cell';
import { useDojo } from '../../dojo/useDojo';
import { Direction } from '../../utils';
import { getEntityIdFromKeys } from '@dojoengine/utils';
import { useComponentValue } from '@dojoengine/react';
import { ActivePath } from '../../App';

interface GridProps {
  rows: number;
  cols: number;
  activePath: ActivePath;
}

const Grid = ({rows, cols, activePath}: GridProps) => {
  const {
    setup: {
      systemCalls: { move_freely },
      clientComponents: { ActivePath },
      dojoProvider,
    },
    account,
  } = useDojo();

  const playerEntityId = getEntityIdFromKeys([
    BigInt(account.account.address)
  ]);
  const player_path = useComponentValue(ActivePath, playerEntityId);

  // useEffect(() => {
  //   console.log('--- player_path ---');
  //   console.log(player_path);
  //   // const fetchBlockTimestamp = async () => (await dojoProvider.provider.getBlock()).timestamp;
  //   // const current_block_timestamp = fetchBlockTimestamp();
  //   // if (current_block_timestamp < player_path?.end_time) {

  //   // }
    
  // }, [player_path]);
// 
  // const current_block_timestamp = (await dojoProvider.provider.getBlock()).timestamp;


  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      switch (event.key) {
        case 'ArrowUp':
          console.log('Up arrow pressed');
          move_freely(account.account, Direction.Up);
          break;
        case 'ArrowDown':
          console.log('Down arrow pressed');
          move_freely(account.account, Direction.Down);
          break;
        case 'ArrowLeft':
          console.log('Left arrow pressed');
          move_freely(account.account, Direction.Left);
          break;
        case 'ArrowRight':
          console.log('Right arrow pressed');
          move_freely(account.account, Direction.Right);
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);

    // Cleanup the event listener on component unmount
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [account.account, move_freely]);

  return (
    <div className="grid">
      {Array.from({length: rows}).map((_, rowIndex) => (
        <div key={rowIndex} className="grid-row">
          {Array.from({length: cols}).map((_, colIndex) => {
            const tileId = rowIndex * cols + colIndex;
            return (
              <Cell
                key={tileId}
                y={rowIndex}
                x={colIndex}
                is_on_active_path={activePath.path.has(tileId) && (!player_path?.completed)}
              />
            )
          })}
        </div>
      ))}
    </div>
  );
};

export default Grid;
