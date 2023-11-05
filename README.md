# Tetris Game in Assembly Language

## Introduction

This project is an implementation of a simplified version of the classic Tetris game in assembly language, designed to run on a NIOS II processor using the `nios2sim` simulator. The game is displayed on the LED array of the Gecko4EPFL board, where players arrange tetrominoes to form continuous lines and earn points.

## Requirements

- `nios2sim` Simulator (compatible with Java 10)
- Gecko4Education-EPFL
- Multicycle Nios II processor

## How to Play

### Game Controls

- **Left/Right Arrows:** Move the tetromino horizontally.
- **Up Arrow:** Rotate the tetromino.
- **Down Arrow:** Accelerate the tetromino fall.

### Gameplay

1. At the start, the LED screen is empty, and the score is zero.
2. Tetrominoes are generated randomly near the top of the screen.
3. Arrange the tetrominoes to form continuous lines from the left to the right edge.
4. Once a line is formed, it disappears, and the score is incremented by 1 point.
5. The game ends when a new tetromino can't fit on the game screen.

## Simulator and Processor Information

The `nios2sim` simulator and the multicycle Nios II processor are designed to emulate the behavior of the Gecko4EPFL board closely. It's crucial to note that the simulation environment does not support `ldb` and `stb` instructions.
