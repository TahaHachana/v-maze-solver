module main

import gg
import maze

const margin = 50
const num_cols = 16
const num_rows = 12
const build_lines_per_frame = 8 // lines revealed per frame while the maze is drawn and carved
const solve_lines_per_frame = 1 // lines revealed per frame while the maze is solved
const window_height = 600
const window_title = 'V Maze Solver'
const window_width = 800

fn frame(mut m maze.Maze) {
	total := m.line_queue.len()
	step := if m.render_level < m.solve_start {
		build_lines_per_frame
	} else {
		solve_lines_per_frame
	}
	m.render_level = if m.render_level + step > total { total } else { m.render_level + step }
	ctx := m.ctx
	ctx.begin()
	for i := 0; i < m.render_level; i++ {
		l := m.line_queue.index(i) or { panic(err) }
		l.draw(ctx)
	}
	ctx.end()
}

fn main() {
	cell_size_x := (window_width - 2 * margin) / num_cols
	cell_size_y := (window_height - 2 * margin) / num_rows
	mut m := maze.Maze.new(margin, margin, num_rows, num_cols, cell_size_x, cell_size_y)

	mut context := gg.new_context(
		bg_color:     gg.rgb(255, 255, 255)
		width:        window_width
		height:       window_height
		window_title: window_title
		user_data:    m
		frame_fn:     frame
	)

	m.ctx = context
	context.run()
}
