extends Sprite


# Called when the node enters the scene tree for the first time.
func init(pcolor):
	texture = pcolor

func _process(_delta):
	modulate.a -= 0.01
	if modulate.a <= 0:
		queue_free()
