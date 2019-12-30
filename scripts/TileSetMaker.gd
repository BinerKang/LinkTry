extends Node2D

var tile_size = Vector2(64, 64)
onready var texture = $Sprite.texture

func _ready():
	var tex_weight = texture.get_width() / tile_size.x
	var tex_height = texture.get_height() / tile_size.y
	var ts = TileSet.new()
	var region 
	var id 
	for x in range(tex_weight):
		for y in range(tex_height):
			region = Rect2(x * tile_size.x, y * tile_size.y, tile_size.x, tile_size.y)
			id = x + y * tex_weight
			ts.create_tile(id)
			ts.tile_set_texture(id, texture)
			ts.tile_set_region(id, region)
	ResourceSaver.save("res://tscn/tiles.tres", ts)
