# V Maze Solver

A small animated maze generator and solver written in [V](https://vlang.io/), drawn with V's built-in `gg` graphics module.

Each run carves a new random maze, then solves it while you watch. The solver draws its path in **red**. When it hits a dead end it backtracks and erases the wrong turn in **white**, so the line that remains at the end is the path from the entrance (top-left) to the exit (bottom-right).

## Requirements

- V **0.5.2** or newer. Run `v up` to update an existing install.
- A C compiler (V ships with `tcc`; `gcc` or `clang` also work).
- On Linux, the X11 and OpenGL development headers that `gg` (sokol) needs:

  ```sh
  # Debian / Ubuntu
  sudo apt install libx11-dev libxi-dev libxcursor-dev libgl-dev
  ```

macOS and Windows need nothing extra.

## Running

From the project root:

```sh
v run .
```

Or build an optimized binary:

```sh
v -prod -o maze_solver .
./maze_solver
```

## Configuration

The tunables are constants at the top of [`main.v`](main.v):

| Constant | Default | Meaning |
| --- | --- | --- |
| `num_cols` / `num_rows` | `16` / `12` | Maze size in cells |
| `window_width` / `window_height` | `800` / `600` | Window size in pixels |
| `margin` | `50` | Space between the maze and the window edge |
| `build_lines_per_frame` | `8` | Lines revealed per frame while the grid is drawn and the maze is carved |
| `solve_lines_per_frame` | `1` | Lines revealed per frame while the solver runs. Lower values slow the solve down |

Cell size comes from the window size, the margin and the grid size.

## How it works

1. **Grid.** `Maze.new` creates a `num_cols × num_rows` grid of cells, each with all four walls up, then removes the entrance and exit walls.
2. **Generation.** `break_walls_r` runs a *randomized depth-first search* (recursive backtracker). Starting at the top-left cell, it moves to a random unvisited neighbour and knocks down the wall between them, and repeats until every cell has been visited. The result is a *perfect* maze: every cell is reachable and there is exactly one path between any two cells.
3. **Solving.** `solve_r` runs a depth-first search from the entrance, trying left, right, up and down in that order. It follows open passages to unvisited cells. When it reaches a dead end it returns `false`, and the caller undoes that move.
4. **Animation.** Generation and solving run before the window opens. Each wall, move and undo is added as a `graphics.Line` to a queue. On every frame, `frame` in `main.v` reveals a few more lines from the queue and redraws everything revealed so far. It reveals many lines per frame while the maze is built and only a few while it is solved, so the build goes by quickly and the solve can be followed.

## Project layout

```
.
├── v.mod               # module manifest
├── main.v              # window setup, config constants, frame loop
├── maze/maze.v         # Cell and Maze: generation and solving
└── graphics/graphics.v # Point and Line drawing primitives
```

## License

MIT
