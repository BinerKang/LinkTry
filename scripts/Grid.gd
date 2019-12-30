extends TileMap

const GRID_START = [1, 1]
const GRID_END = [14, 10]

var map_size = Vector2(16, 12)

var _point_path : Array = []
var zero_points = []
var one_points = []
var two_points = []

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#8bf40b')

onready var _half_cell_size = cell_size / 2

func recalculate_path(start_pos, end_pos):
	_point_path = []
	var success = check_zero(start_pos, end_pos)
	if !success: # 未成功则检测一折
		success = check_one(start_pos, end_pos)
		if !success: # 未成功则检测二折
			success = check_two(start_pos, end_pos)
			if success: #2折成功代表绘制4个点
				_point_path = two_points
		else: #一折成功代表绘制3个点
			_point_path = one_points
	else: # 0折成功代表只用绘制开始和结束点
		_point_path.append(start_pos)
		_point_path.append(end_pos)
	update()
	return success
		
# 0折 这种情况两个选中目标的横坐标或者纵坐标是一样的。只要再判断连线上没有阻碍即可。
func check_zero(start_pos, end_pos):
	zero_points = []
	if start_pos == end_pos:
		return true
	var vector = end_pos - start_pos
	if vector.x != 0 && vector.y != 0:
		return false
	if vector.x == 0:
		var dir = vector.y / abs(vector.y)
		for i in range(1, abs(vector.y)):
			i *= dir 
			zero_points.append(start_pos + Vector2(0, i))
	if vector.y == 0:
		var dir = vector.x / abs(vector.x)
		for i in range(1, abs(vector.x)):
			i *= dir 
			zero_points.append(start_pos + Vector2(i, 0))
	# 靠在一起
	if len(zero_points) == 0:
		return true
	return no_obstacles(zero_points)

#两个目标横纵坐标都不能相等，相当于矩形上的对角点。所以要判断两个点是否
#满足1折连就只要确定另外两个对角点上的任一点同时对A和B满足0折连的情况即可。
func check_one(start_pos, end_pos):
	#对角点1,2
	var dia_one = Vector2(end_pos.x, start_pos.y)
	if not_obstacles(dia_one) && check_zero(dia_one, start_pos) && check_zero(dia_one, end_pos):
		record_one_points(start_pos, dia_one, end_pos)
		return true
	var dia_two = Vector2(start_pos.x, end_pos.y)
	if not_obstacles(dia_two) && check_zero(dia_two, start_pos) && check_zero(dia_two, end_pos):
		record_one_points(start_pos, dia_two, end_pos)
		return true
	return false

func record_one_points(start_pos, mid_point, end_pos):
	one_points = [] 
	one_points.append(start_pos)
	one_points.append(mid_point)
	one_points.append(end_pos)

#向四周查找空格区域，直到“撞墙”，然后记录点C。再看点C是否满足与B 1折连情况。
func check_two(start_pos, end_pos):
	# 从start_pos向上找
	var tmp_point = null
	for i in range(start_pos.y - 0):
		tmp_point = start_pos - Vector2(0, i + 1)
		if not_obstacles(tmp_point): #不是障碍检测是否符合一折，不符合继续向上
			if check_one(tmp_point, end_pos):
				record_two_points(start_pos)
				return true
		else: #是障碍结束
			break	
	# 从start_pos向下找
	for i in range(map_size.y - start_pos.y - 1):
		tmp_point = start_pos + Vector2(0, i + 1)
		if not_obstacles(tmp_point): #不是障碍检测是否符合一折，不符合继续向下
			if check_one(tmp_point, end_pos):
				record_two_points(start_pos)
				return true
		else: #是障碍结束
			break
	# 从start_pos向左找
	for i in range(start_pos.x - 0):
		tmp_point = start_pos - Vector2(i + 1, 0)
		if not_obstacles(tmp_point): #不是障碍检测是否符合一折，不符合继续向左
			if check_one(tmp_point, end_pos):
				record_two_points(start_pos)
				return true
		else: #是障碍结束
			break

	# 从start_pos向右找
	for i in range(map_size.x - start_pos.x - 1):
		tmp_point = start_pos + Vector2(i + 1, 0)
		if not_obstacles(tmp_point): #不是障碍检测是否符合一折，不符合继续向右
			if check_one(tmp_point, end_pos):
				record_two_points(start_pos)
				return true
		else: #是障碍结束
			break
	return false

func record_two_points(start_point):
	two_points = []
	two_points = one_points
	two_points.insert(0, start_point)
		
func not_obstacles(point):
	var tile = get_cell(point.x, point.y)
	if tile >= 0: 
		return false
	else:
		return true
	
func no_obstacles(points : Array):
	for point in points:
		var tile = get_cell(point.x, point.y)
		if tile >= 0:
			return false
	return true
	

func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		last_point = current_point

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y
