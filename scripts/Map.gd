extends Node2D

signal match_success

var start_num = 10 # 开始时的动物数量
var level = 0
var first_tile = null
var first_pos = null

onready var Map = $Grid
onready var Lighter = $Grid/GridLighter

func init(level):
	set_start_num(level)
	make_map()
	show_game()

func show_game():
	$AnimationPlayer.play("game_in")
	
func hide_game():
	$AnimationPlayer.play("game_out")

func set_start_num(level):
	start_num += level
	
func make_map():
	for x in range(Map.GRID_START[0], Map.GRID_END[0] + 1):
		for y in range(Map.GRID_START[1], Map.GRID_END[1] + 1):
			Map.set_cellv(Vector2(x, y), randTile())

func randTile():
	return randi() %  (start_num + level)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var tile_pos = Map.world_to_map(event.position)
			var tile = Map.get_cell(tile_pos.x, tile_pos.y)
			if tile < 0:
				return
			# 如果没缓存，赋值并高亮
			if first_tile == null:
				first_tile = tile
				first_pos = tile_pos
				Lighter.refresh(tile_pos)
			else:
				if first_pos == tile_pos: # 如果是相同的位置 不处理
					return
				if first_tile != tile: # 如果标题不一样，恢复 则去除高亮
					match_fail()
				else: # 检查是否超过2个拐点
					var isSuccess = Map.recalculate_path(first_pos, tile_pos)
					if isSuccess:
						match_success(tile_pos)
					else:
						match_fail()
# 重置缓存					
func reset_cache():
	first_tile = null
	Lighter.refresh(null)

func match_success(second_pos):
	reset_cache()
	if settings.enable_sound:
		$MatchSuccessAudio.play()
	#去掉这两个tile
	Map.set_cellv(first_pos, -1)
	Map.set_cellv(second_pos, -1)
	#爆炸消失
	explode(first_pos, second_pos)
	yield(get_tree().create_timer(0.3), "timeout")
	Map._point_path = []
	Map.update()
	emit_signal("match_success")
	
func explode(fir_pos, sec_pos):
	$Explosion.position = Map.map_to_world(fir_pos) + Map._half_cell_size
	$Explosion2.position = Map.map_to_world(sec_pos) + Map._half_cell_size
	$Explosion.frame = 0
	$Explosion2.frame = 0
	$Explosion.show()
	$Explosion2.show()
	$Explosion.play("smoke")
	$Explosion2.play("smoke")
	
func match_fail():
	reset_cache()
	if settings.enable_sound:
		$MatchFailAudio.play()

func is_pass():
	var cells = $Grid.get_used_cells()
	if len(cells) > start_num:
		return false
	var tmp_cell = null
	for cell in cells:
		if tmp_cell == cell:
			return false
		tmp_cell = cell
	return true
