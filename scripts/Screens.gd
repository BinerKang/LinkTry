extends Node2D

signal start_game

var current_screen
var sound_buttons = {true: preload("res://assets/img/sound.png"), 
						false: preload("res://assets/img/nosound.png")}
var music_buttons = {true: preload("res://assets/img/music.png"), 
						false: preload("res://assets/img/nomusic.png")}

func _ready():
	register_buttons()
	change_screen($TitleScreen)
	
func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])

func _on_button_pressed(button):
	if settings.enable_sound:
		$Switch.play()
	match button.name:
		"Home":
			change_screen($TitleScreen)
		"Play":
			change_screen(null)
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("start_game")
		"Settings":
			change_screen($SettingsScreen)
		"Sound":
			settings.enable_sound = !settings.enable_sound
			button.texture_normal = sound_buttons[settings.enable_sound]
		"Music":
			settings.enable_music = !settings.enable_music
			button.texture_normal = music_buttons[settings.enable_music]
		
func change_screen(new_screen):
	# 隐藏之前的，显示新的
	if current_screen:
		current_screen.disapper()
		yield(current_screen.tween, "tween_completed")
	current_screen = new_screen
	if new_screen:
		new_screen.appear()
		yield(new_screen.tween, "tween_completed")
	
func game_over():
	change_screen($GameoverScreen)
