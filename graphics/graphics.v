module graphics

import gg

pub struct Point {
pub mut:
	x int
	y int
}

// Point.new returns a point at pixel coordinates (x, y).
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

// Line.new returns a line segment from p1 to p2, drawn in the named color.
pub fn Line.new(p1 Point, p2 Point, color string) Line {
	return Line{
		p1:    p1
		p2:    p2
		color: color
	}
}

// draw renders the line on the given graphics context.
pub fn (l Line) draw(ctx &gg.Context) {
	ctx.draw_line(l.p1.x, l.p1.y, l.p2.x, l.p2.y, gg.color_from_string(l.color))
}
