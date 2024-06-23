module main

import gg
import gx
import maze
import time

const margin = 50
const num_cols = 16
const num_rows = 12
const sleep_time = 3000000
const window_height = 600
const window_title = 'V Maze Solver'
const window_width = 800

fn frame(mut m maze.Maze) {
	if m.render_level == m.line_queue.len() {
		return
	}
	time.sleep(sleep_time)
	ctx := m.ctx
	ctx.begin()
	for i := 0; i <= m.render_level; i++ {
		l := m.line_queue.index(i) or { panic(err) }
		l.draw(ctx)
	}
	ctx.end()
	m.render_level++
}

fn main() {
	cell_size_x := (window_width - 2 * margin) / num_cols
	cell_size_y := (window_height - 2 * margin) / num_rows
	mut m := maze.Maze.new(margin, margin, num_rows, num_cols, cell_size_x, cell_size_y)

	mut context := gg.new_context(
		bg_color: gx.rgb(255, 255, 255)
		width: window_width
		height: window_height
		window_title: window_title
		init_fn: fn (mut ctx gg.Context) {
			ctx.begin()
			ctx.end()
		}
		user_data: m
		frame_fn: frame
	)

	m.ctx = context
	context.run()
}
