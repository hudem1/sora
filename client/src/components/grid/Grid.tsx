import React, { FC } from 'react';
import './Grid.css';

interface GridProps {
  rows: number;
  cols: number;
}

const Grid: FC<GridProps> = ({ rows, cols }) => {
  const grid = Array.from({ length: rows }, () => Array.from({ length: cols }, () => 0));

  return (
    <div className="grid">
      {grid.map((row, rowIndex) => (
        <div key={rowIndex} className="grid-row">
          {row.map((cell, colIndex) => (
            <div key={colIndex} className="grid-cell">
              {cell}
            </div>
          ))}
        </div>
      ))}
    </div>
  );
};

export default Grid;
