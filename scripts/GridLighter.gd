extends Node2D

var draw_pos = null
var LINE_COLOR = Color("#cee911")
var LINE_WIDTH = 6

onready var grid = get_parent()

func _process(_delta):
	update()

func _draw():
	if draw_pos == null:
		return
	var col_start = draw_pos.x * grid.cell_size.x
	var row_start = draw_pos.y * grid.cell_size.y
	var col_end = col_start + grid.cell_size.x
	var row_end = row_start + grid.cell_size.y
	draw_line(Vector2(col_start, row_start), Vector2(col_start, row_end), LINE_COLOR, LINE_WIDTH)
	draw_line(Vector2(col_start, row_start), Vector2(col_end, row_start), LINE_COLOR, LINE_WIDTH)
	draw_line(Vector2(col_end, row_start), Vector2(col_end, row_end), LINE_COLOR, LINE_WIDTH)
	draw_line(Vector2(col_start, row_end), Vector2(col_end, row_end), LINE_COLOR, LINE_WIDTH)

func refresh(_draw_pos):
	draw_pos = _draw_pos
