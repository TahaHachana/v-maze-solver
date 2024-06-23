module main

import gg
import gx
import math
import rand
import time
import datatypes

struct Point {
mut:
	x int
	y int
}

fn Point.new(x int, y int) Point {
	return Point{
		x: x
		y: y
	}
}

struct Line {
	p1 Point
	p2 Point
	color string
}

fn Line.new(p1 Point, p2 Point, color string) Line {
	return Line{
		p1: p1
		p2: p2
		color: color
	}
}

fn (l Line) draw(ctx gg.Context) {
	ctx.draw_line(l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.color_from_string(l.color))
}

const wall_color = 'black'
const no_wall_color = 'white'
const fill_color = 'red'
const backtrack_color = 'white' //'gray'

struct Cell {
mut:
	has_left_wall   bool
	has_right_wall  bool
	has_top_wall    bool
	has_bottom_wall bool
	visited         bool
	x1              int
	x2              int
	y1              int
	y2              int
	ctx             gg.Context
}

fn Cell.new(ctx gg.Context) Cell {
	return Cell{
		has_left_wall: true
		has_right_wall: true
		has_top_wall: true
		has_bottom_wall: true
		visited: false
		x1: 0
		x2: 0
		y1: 0
		y2: 0
		ctx: ctx
	}
}

fn (c Cell) draw_wall(x1 int, y1 int, x2 int, y2 int, has_wall bool, mut m Maze) {
	color := if has_wall { wall_color } else { no_wall_color }
	line := Line.new(Point.new(x1, y1), Point.new(x2, y2), color)
	m.line_queue.push(line)
	//	line.draw(c.ctx, color)
}

fn (mut c Cell) draw(x1 int, y1 int, x2 int, y2 int, mut m Maze) {
	c.x1 = x1
	c.x2 = x2
	c.y1 = y1
	c.y2 = y2
	// println(c.ctx.frame)
	// time.sleep(500)
	c.draw_wall(x1, y1, x2, y1, c.has_top_wall, mut m)
	c.draw_wall(x2, y1, x2, y2, c.has_right_wall, mut m)
	c.draw_wall(x1, y2, x2, y2, c.has_bottom_wall, mut m)
	c.draw_wall(x1, y1, x1, y2, c.has_left_wall, mut m)
}

fn (c Cell) draw_move(to_cell Cell, undo bool, mut m Maze) {
	half_length := math.abs(c.x2 - c.x1) / 2
	x_center := half_length + c.x1
	y_center := half_length + c.y1

	half_length2 := math.abs(to_cell.x2 - to_cell.x1) / 2
	x_center2 := half_length2 + to_cell.x1
	y_center2 := half_length2 + to_cell.y1

	color := if undo { backtrack_color } else { fill_color }
	line := Line.new(Point.new(x_center, y_center), Point.new(x_center2, y_center2), color)
	m.line_queue.push(line) //<< line
	//	line.draw(c.ctx, color)
}

struct Maze {
mut:
	cells        [][]Cell
	x1           int
	y1           int
	num_rows     int
	num_cols     int
	cell_size_x  int
	cell_size_y  int
	ctx          gg.Context
	seed         int
	line_queue   datatypes.Queue[Line]
	render_level int
}

fn Maze.new(x1 int, y1 int, num_rows int, num_cols int, cell_size_x int, cell_size_y int, ctx gg.Context, seed int) Maze {
	mut maze := Maze{
		cells: [][]Cell{}
		x1: x1
		y1: y1
		num_rows: num_rows
		num_cols: num_cols
		cell_size_x: cell_size_x
		cell_size_y: cell_size_y
		ctx: ctx
		seed: seed
		line_queue: datatypes.Queue[Line]{}
	}
	maze.create_cells()
	maze.break_entrance_and_exit()
	maze.break_walls_r(0, 0)
	maze.reset_cells_visited()
	maze.solve()
	return maze
}

fn (mut m Maze) draw_cell(i int, j int) {
	x1 := m.x1 + i * m.cell_size_x
	y1 := m.y1 + j * m.cell_size_y
	x2 := x1 + m.cell_size_x
	y2 := y1 + m.cell_size_y
	m.cells[i][j].draw(x1, y1, x2, y2, mut m)
}

fn (mut m Maze) create_cells() {
	for i := 0; i < m.num_cols; i++ {
		mut col_cells := []Cell{}
		for j := 0; j < m.num_rows; j++ {
			col_cells << Cell.new(m.ctx)
		}
		m.cells << col_cells
	}
	for i := 0; i < m.num_cols; i++ {
		for j := 0; j < m.num_rows; j++ {
			m.draw_cell(i, j)
		}
	}
}

fn (mut m Maze) break_entrance_and_exit() {
	// Entrance
	m.cells[0][0].has_top_wall = false
	m.draw_cell(0, 0)
	// Exit
	m.cells[m.num_cols - 1][m.num_rows - 1].has_bottom_wall = false
	m.draw_cell(m.num_cols - 1, m.num_rows - 1)
}

struct Index {
	i int
	j int
}

fn (mut m Maze) break_walls_r(i int, j int) {
	m.cells[i][j].visited = true
	for {
		mut next_index_arr := []Index{}

		// determine which cell(s) to visit next
		// left
		if i > 0 && !m.cells[i - 1][j].visited {
			next_index_arr << Index{i - 1, j}
		}
		// right
		if i < m.num_cols - 1 && !m.cells[i + 1][j].visited {
			next_index_arr << Index{i + 1, j}
		}
		// up
		if j > 0 && !m.cells[i][j - 1].visited {
			next_index_arr << Index{i, j - 1}
		}
		// down
		if j < m.num_rows - 1 && !m.cells[i][j + 1].visited {
			next_index_arr << Index{i, j + 1}
		}

		// if there is nowhere to go from here
		// just break out
		if next_index_arr.len == 0 {
			m.draw_cell(i, j)
			return
		}

		// randomly choose the next direction to go
		direction_index := rand.int_in_range(0, next_index_arr.len) or { 0 }
		next_index := next_index_arr[direction_index]

		// knock out walls between this cell and the next cell(s)
		// right
		if next_index.i == i + 1 {
			m.cells[i][j].has_right_wall = false
			m.cells[i + 1][j].has_left_wall = false
		}
		// left
		if next_index.i == i - 1 {
			m.cells[i][j].has_left_wall = false
			m.cells[i - 1][j].has_right_wall = false
		}
		// down
		if next_index.j == j + 1 {
			m.cells[i][j].has_bottom_wall = false
			m.cells[i][j + 1].has_top_wall = false
		}
		// up
		if next_index.j == j - 1 {
			m.cells[i][j].has_top_wall = false
			m.cells[i][j - 1].has_bottom_wall = false
		}

		// recursively visit the next cell
		m.break_walls_r(next_index.i, next_index.j)
	}
}

fn (mut m Maze) solve_r(i int, j int) bool {
	// visit the current cell
	m.cells[i][j].visited = true

	// if we are at the end cell, we are done!
	if i == m.num_cols - 1 && j == m.num_rows - 1 {
		return true
	}

	// move left if there is no wall and it hasn't been visited
	if i > 0 && !m.cells[i][j].has_left_wall && !m.cells[i - 1][j].visited {
		m.cells[i][j].draw_move(m.cells[i - 1][j], false, mut m)
		if m.solve_r(i - 1, j) {
			return true
		} else {
			m.cells[i][j].draw_move(m.cells[i - 1][j], true, mut m)
		}
	}

	// move right if there is no wall and it hasn't been visited
	if i < m.num_cols - 1 && !m.cells[i][j].has_right_wall && !m.cells[i + 1][j].visited {
		m.cells[i][j].draw_move(m.cells[i + 1][j], false, mut m)
		if m.solve_r(i + 1, j) {
			return true
		} else {
			m.cells[i][j].draw_move(m.cells[i + 1][j], true, mut m)
		}
	}

	// move up if there is no wall and it hasn't been visited
	if j > 0 && !m.cells[i][j].has_top_wall && !m.cells[i][j - 1].visited {
		m.cells[i][j].draw_move(m.cells[i][j - 1], false, mut m)
		if m.solve_r(i, j - 1) {
			return true
		} else {
			m.cells[i][j].draw_move(m.cells[i][j - 1], true, mut m)
		}
	}

	// move down if there is no wall and it hasn't been visited
	if j < m.num_rows - 1 && !m.cells[i][j].has_bottom_wall && !m.cells[i][j + 1].visited {
		m.cells[i][j].draw_move(m.cells[i][j + 1], false, mut m)
		if m.solve_r(i, j + 1) {
			return true
		} else {
			m.cells[i][j].draw_move(m.cells[i][j + 1], true, mut m)
		}
	}

	// we went the wrong way let the previous cell know by returning False
	return false
}

fn (mut m Maze) solve() bool {
	return m.solve_r(0, 0)
}

fn (mut m Maze) reset_cells_visited() {
	for i := 0; i < m.num_cols; i++ {
		for j := 0; j < m.num_rows; j++ {
			m.cells[i][j].visited = false
		}
	}
}

const window_width = 800
const window_height = 600
const window_title = 'V Maze Solver'
const num_rows = 12
const num_cols = 16
const margin = 50

fn main() {
	cell_size_x := (window_width - 2 * margin) / num_cols
	cell_size_y := (window_height - 2 * margin) / num_rows

	mut maze := &Maze{
		cells: [][]Cell{}
		x1: margin
		y1: margin
		num_rows: num_rows
		num_cols: num_cols
		cell_size_x: cell_size_x
		cell_size_y: cell_size_y
		// ctx: ctx
		seed: 0
		line_queue: datatypes.Queue[Line]{}
		render_level: 0
	}
	maze.create_cells()
	maze.break_entrance_and_exit()
	maze.break_walls_r(0, 0)
	maze.reset_cells_visited()
	maze.solve()
	println(maze.line_queue.len())

	mut context := gg.new_context(
		// gg.start(
		bg_color: gx.rgb(255, 255, 255)
		width: window_width
		height: window_height
		window_title: window_title
		// init_fn: fn (mut ctx gg.Context) {
		// 	ctx.begin()
		// 	ctx.end()
		// }
		user_data: maze
		frame_fn: frame
		// ui_mode: true
	)
	// mut maze := Maze.new(margin, margin, num_rows, num_cols, cell_size_x, cell_size_y,
	// 	context, 0)
	maze.cell_size_x = cell_size_x
	maze.cell_size_y = cell_size_y
	maze.ctx = context

	context.run()
	// println(maze.line_queue.len())

	// context.begin()
	// l := maze.line_queue.pop() or { panic(err) }
	// l.draw(context, "black")
	// context.end()
	// frame(mut context, mut maze)
	// gg.start(context)
	// context.run()
}

fn frame(mut m Maze) {
	if m.render_level == m.line_queue.len() - 1 {
		//println("done")
		return
	}
	time.sleep(5000000)
	//println(m.line_queue.len())
	ctx := m.ctx
	ctx.begin()
	for i := 0; i <= m.render_level; i++ {
		l := m.line_queue.index(i) or { panic(err) }
		l.draw(ctx)
	}
	// ctx.draw_line(l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.color_from_string("black"))

//	l.draw(ctx, 'black')
	// cell_size_x := (window_width - 2 * margin) / num_cols
	// cell_size_y := (window_height - 2 * margin) / num_rows
	// mut maze := Maze.new(margin, margin, num_rows, num_cols, cell_size_x, cell_size_y,
	// 	ctx, 0)
	// maze.create_cells()
	// maze.break_entrance_and_exit()
	// maze.break_walls_r(0, 0)
	// maze.reset_cells_visited()
	// is_solveable := maze.solve()
	// if not is_solveable:
	//     print("maze cannot be solved!")
	// else:
	//     print("maze solved!")
	ctx.end()
	// time.sleep(500000000)
	m.render_level++
}
