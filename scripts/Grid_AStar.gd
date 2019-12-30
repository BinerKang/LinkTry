extends TileMap

const GRID_START = [1, 1]
const GRID_END = [14, 10]

# You can only create an AStar node from code, not from the Scene tab
onready var astar_node = AStar.new()

var map_size = Vector2(16, 12)

var _point_path = []

var obstacles = []

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')

onready var _half_cell_size = cell_size / 2

func refresh_astar(obstacles):	
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)

# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacles:
				continue

			points_array.append(point)
			# The AStar class references points with indices
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array

# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)

func recalculate_path(path_start_position, path_end_position):
	# get_used_cells is a method from the TileMap node
	# here the used corresponds to the grey tile, the obstacles
	obstacles = get_used_cells()
	obstacles.erase(path_start_position)
	obstacles.erase(path_end_position)
	refresh_astar(obstacles)
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	return check_path()

func check_path():
	if len(_point_path) == 0:
		return false
	# 用后一个点减去前一个点得到向量，如果角度一样则代表没有转折
	var tempVector = null
	var count = 0	
	for x in range(len(_point_path)):
		if (x + 1) == len(_point_path):
			break
		var vector = _point_path[x+1] - _point_path[x]
		if x == 0:
			tempVector = vector
			continue
		if tempVector != vector:
			count += 1
		if count > 2:
			return false
		tempVector = vector
	return true
	
func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		last_point = current_point

func calculate_point_index(point):
	return point.x + map_size.x * point.y

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y
