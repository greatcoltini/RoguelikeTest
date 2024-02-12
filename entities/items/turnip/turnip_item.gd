extends Node2D

var item_name
var item_quantity

@onready var label = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	item_name = "Turnip"
	$Sprite2D.texture = load("res://entities/item_drops/" + item_name + ".png")
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	item_quantity = randi() % stack_size + 1
	
	if stack_size == 1:
		label.visible = false
	else:
		label.text = str(item_quantity)
		
func add_item_quantity(amount):
	item_quantity += amount
	label.text = str(item_quantity)
	
func decrease_item_quantity(amount):
	item_quantity -= amount
	label.text = str(item_quantity)
	
func set_item(new_name, quantity):
	if new_name != null:
		item_name = new_name
		item_quantity = quantity
		
		$Sprite2D.texture = load("res://entities/item_drops/" + item_name + ".png")
		
		var stack_size = int(JsonData.item_data[item_name]["StackSize"])
		
		if stack_size == 1:
			label.visible = false
		else:
			label.visible = true
			label.text = str(item_quantity) 

func remove():
	if item_quantity < 1:
		queue_free()
