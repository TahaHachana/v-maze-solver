module graphics

import gg
import gx

pub struct Point {
pub mut:
	x int
	y int
}

pub fn Point.new(x int, y int) Point {
	return Point{
		x: x
		y: y
	}
}

pub struct Line {
	p1    Point
	p2    Point
	color string
}

pub fn Line.new(p1 Point, p2 Point, color string) Line {
	return Line{
		p1: p1
		p2: p2
		color: color
	}
}

pub fn (l Line) draw(ctx gg.Context) {
	ctx.draw_line(l.p1.x, l.p1.y, l.p2.x, l.p2.y, gx.color_from_string(l.color))
}
