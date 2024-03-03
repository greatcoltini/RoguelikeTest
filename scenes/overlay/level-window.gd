extends GridContainer

signal dmgUP
signal hpUP

@onready var damage = $'dmg-level'
@onready var hp = $'hp-level'
@export var ui : CanvasLayer

func _ready():
	# connect signals for level up windows
	damage.connect("mouse_entered", _on_hover.bind(damage))
	hp.connect("mouse_entered", _on_hover.bind(hp))
	damage.connect("mouse_exited", _on_leave.bind(damage))
	hp.connect("mouse_exited", _on_leave.bind(hp))
	

func on_click_hp(event: InputEvent):
	if event.is_action_pressed("attack"):
		emit_signal("hpUP")
		self.visible = false
		empty_shards()
	
func on_click_dmg(event: InputEvent):
	if event.is_action_pressed("attack"):
		emit_signal("dmgUP")
		self.visible = false
		empty_shards()
		
func _on_hover(obj):
	var tween = create_tween()
	tween.tween_property(obj, "modulate:a", 0.5, 0.5)
	
func _on_leave(obj):
	var tween = create_tween()
	tween.tween_property(obj, "modulate:a", 1, 0.1)
		
func empty_shards():
	Globals.GAME_PAUSED = false
	ui.soul_shards.value = 0
