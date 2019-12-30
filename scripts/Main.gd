extends Node2D

var max_time = 240
var score = 0
var level = 0
var left_time

func _ready():
	randomize()
	$HUD.hide()
	
func new_game(score=0, level=0):
	$Map.init(level)
	left_time = max_time
	$HUD.set_timebar_max_vaule(max_time)
	$HUD.update_timebar(max_time)
	$HUD.update_score(score)
	$HUD.show()
	$Timer.start()
	if settings.enable_music:
		$Music.play()

func _on_Screens_start_game():
	new_game()

func game_over():
	$Timer.stop()
	$Map.hide_game()
	$Music.stop()
	$Screens.game_over()
	
func _on_Timer_timeout():
	left_time -= 1
	$HUD.update_timebar(left_time)
	if left_time < 1:
		game_over()

func _on_Map_match_success():
	score += 1
	$HUD.update_score(score)
	# 是否过关
	var is_pass = $Map.is_pass()
	if is_pass:
		$Map.hide_game()
		$Music.stop()
		$WellDone.play()

func _on_WellDone_finished():
	level += 1
	$HUD.update_level(level)
	new_game(score, level)
