extends CanvasLayer

onready var tween = $Tween

func appear():
	tween.interpolate_property(self, "offset:y", -800, 0,
		0.6, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()

func disapper():
	tween.interpolate_property(self, "offset:y", 0, -800, 
		0.6, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	tween.start()
