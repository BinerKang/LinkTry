extends Node2D

onready var grid = get_parent()

func _draw():
	var LINE_COLOR = Color("#12d32c")
	var LINE_WIDTH = 2

	var col_num = grid.GRID_END[0] + 1 # 列的数量
	var row_num = grid.GRID_END[1] + 1 # 行的数量
	var x_offset = 1 # 离原点偏移1格
	var y_offset = 1 # 离原点偏移1格
	for x in range(col_num):
		var col_pos = (x + x_offset) * grid.cell_size.x
		var limit_start = grid.GRID_START[1] * grid.cell_size.y
		var limit_end = row_num * grid.cell_size.y
		draw_line(Vector2(col_pos, limit_start), Vector2(col_pos, limit_end), LINE_COLOR, LINE_WIDTH)
	for y in range(row_num):
		var row_pos = (y + y_offset) * grid.cell_size.y
		var limit_start = grid.GRID_START[0] * grid.cell_size.x
		var limit_end = col_num * grid.cell_size.x
		draw_line(Vector2(limit_start, row_pos), Vector2(limit_end, row_pos), LINE_COLOR, LINE_WIDTH)
