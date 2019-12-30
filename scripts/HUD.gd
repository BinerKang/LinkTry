extends CanvasLayer

var bar_green = preload("res://assets/img/green_320.png")
var bar_red = preload("res://assets/img/red_320.png")
var bar_yellow = preload("res://assets/img/yellow_320.png")
var bar_texture

func set_timebar_max_vaule(max_value):
	$Margin/HBoxContainer/TimeContainer/TimeBar.max_value = max_value

func update_timebar(value):
	bar_texture = bar_green
	var percent = value / $Margin/HBoxContainer/TimeContainer/TimeBar.max_value * 100
	if percent < 60:
		bar_texture = bar_yellow
	if percent < 20:
		bar_texture = bar_red	
	$Margin/HBoxContainer/TimeContainer/TimeBar.texture_progress = bar_texture
	$Margin/HBoxContainer/TimeContainer/TimeBar.value = value
	$Margin/HBoxContainer/TimeContainer/Time.text = str(value)
	
func update_score(val):
	$ScoreMargin/ScoreContainer/Score.text = str(val)

func update_level(val):
	$ScoreMargin/ScoreContainer/Level.text = str(val)

func hide():
	$Margin.hide()
	$ScoreMargin.hide()
	
func show():
	$Margin.show()
	$ScoreMargin.show()
