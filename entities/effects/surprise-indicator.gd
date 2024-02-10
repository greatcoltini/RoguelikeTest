extends Node2D


@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D


func _ready():
	anim.play("play")

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
	
func image_type(image):
	sprite = $Sprite2D
	sprite.texture = load(image)
	anim = $AnimationPlayer
	anim.play("play")
