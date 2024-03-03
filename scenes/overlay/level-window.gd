extends GridContainer

signal dmgUP
signal hpUP

@onready var damage = $'dmg-level'
@onready var hp = $'hp-level'
@onready var ui = $UI

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
		
func empty_shards():
	ui.soul_shards.value = 0
