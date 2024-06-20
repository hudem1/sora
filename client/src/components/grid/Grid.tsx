import React from 'react';
import './Grid.css';
import Cell from '../cell/Cell';

interface GridProps {
  rows: number;
  cols: number;
}

const Grid = ({rows, cols}: GridProps) => {

  return (
    <div className="grid">
      {Array.from({length: rows}).map((_, rowIndex) => (
        <div key={rowIndex} className="grid-row">
          {Array.from({length: cols}).map((_, colIndex) => (
            <Cell key={rowIndex.toString() + colIndex.toString()}  x={rowIndex} y={colIndex} />
          ))}
        </div>
      ))}
    </div>
  );
};

export default Grid;
