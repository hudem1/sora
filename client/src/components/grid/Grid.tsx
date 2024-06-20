import React, { useEffect } from 'react';
import './Grid.css';
import Cell from '../cell/Cell';
import { useDojo } from '../../dojo/useDojo';
import { Direction } from '../../utils';

interface GridProps {
  rows: number;
  cols: number;
}

const Grid = ({rows, cols}: GridProps) => {
  const {
    setup: {
      systemCalls: { move },
    },
    account,
  } = useDojo();

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      switch (event.key) {
        case 'ArrowUp':
          console.log('Up arrow pressed');
          move(account.account, Direction.Up);
          break;
        case 'ArrowDown':
          console.log('Down arrow pressed');
          move(account.account, Direction.Down);
          break;
        case 'ArrowLeft':
          console.log('Left arrow pressed');
          move(account.account, Direction.Left);
          break;
        case 'ArrowRight':
          console.log('Right arrow pressed');
          move(account.account, Direction.Right);
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);

    // Cleanup the event listener on component unmount
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [account.account, move]);

  return (
    <div className="grid">
      {Array.from({length: rows}).map((_, rowIndex) => (
        <div key={rowIndex} className="grid-row">
          {Array.from({length: cols}).map((_, colIndex) => (
            <Cell key={rowIndex.toString() + colIndex.toString()} y={rowIndex} x={colIndex} />
          ))}
        </div>
      ))}
    </div>
  );
};

export default Grid;
