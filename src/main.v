module main

import gg
import gx

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
}

fn Line.new(p1 Point, p2 Point) Line {
	return Line{
		p1: p1
		p2: p2
	}
}

fn (l Line) draw(ctx gg.Context, fill_color string) {
	ctx.draw_line(l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.color_from_string(fill_color))
}

const wall_color = 'black'
const no_wall_color = 'white'
const fill_color = 'red'
const backtrack_color = 'gray'

struct Cell {
mut:
	has_left_wall   bool
	has_right_wall  bool
	has_top_wall    bool
	has_bottom_wall bool
	visited         bool
	x1              int
	y1              int
	x2              int
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
		y1: 0
		x2: 0
		y2: 0
		ctx: ctx
	}
}

fn (c Cell) draw_wall(has_wall bool) {
	color := if has_wall { backtrack_color } else { no_wall_color }
	line := Line.new(Point.new(c.x1, c.y1), Point.new(c.x2, c.y2))
	line.draw(c.ctx, color)
}

fn (mut c Cell) draw(x1 int, y1 int, x2 int, y2 int) {
	c.x1 = x1
	c.y1 = y1
	c.x2 = x2
	c.y2 = y2
	c.draw_wall(c.has_top_wall)
	c.draw_wall(c.has_right_wall)
	c.draw_wall(c.has_bottom_wall)
	c.draw_wall(c.has_left_wall)
}

const window_width = 800
const window_height = 600
const window_title = 'V Maze Solver'

fn main() {
	mut context := gg.new_context(
		bg_color: gx.rgb(255, 255, 255)
		width: window_width
		height: window_height
		window_title: window_title
		frame_fn: frame
	)
	context.run()
}

fn frame(mut ctx gg.Context) {
	ctx.begin()
	mut cell := Cell.new(ctx)
	cell.draw(0, 0, 100, 100)
//	ctx.draw_line(10, 10, 100, 100, gx.black)
	// ctx.draw_convex_poly([f32(100.0), 100.0, 200.0, 100.0, 300.0, 200.0, 200.0, 300.0, 100.0, 300.0],
	//     gx.blue)
	// ctx.draw_poly_empty([f32(50.0), 50.0, 70.0, 60.0, 90.0, 80.0, 70.0, 110.0], gx.black)
	// ctx.draw_triangle_filled(450, 142, 530, 280, 370, 280, gx.red)
	ctx.end()
}
