extends Node2D

@onready var timer = $Timer
@onready var itembar = $"item-bar"
@onready var item_name_field = $"item-bar/item_name"

var ItemClass = preload("res://entities/items/turnip/turnip_item.tscn")
var item = null
	
func play_toast(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		itembar.add_child(item)
		item.position = Vector2i(-24, 0)
		item.set_item(item_name, item_quantity)
	else:
		if item_name == item.item_name:
			item.set_item(item_name, item.item_quantity + item_quantity)
		else: 
			item.set_item(item_name, item_quantity)
	item_name_field.text = item_name
	timer.start(2)
	visible = true
	
func _on_timer_timeout():
	visible = false # Replace with function body.
