extends Panel

signal item_change

var default_tex = preload("res://assets/item_slot_filled.png")
var empty_tex = preload("res://assets/item_slot_empty.png")
var selected_tex = preload("res://assets/item_slot_selected.png")

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://entities/items/turnip/turnip_item.tscn")
@onready var item = null
var slot_type
var slot_index

enum SlotType {
	HOTBAR,
	INVENTORY,
	CROP,
	FUEL,
	SMELT,
	BOSS
}

# Called when the node enters the scene tree for the first time.
func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	empty_style.texture = empty_tex
	selected_style.texture = selected_tex
	
	#PlayerInventory.item_inventory_changed.connect(self.update_slot)
	
	refresh_style()

func refresh_style():
	emit_signal("item_change")
	if slot_type == SlotType.HOTBAR and PlayerInventory.active_item_slot == slot_index:
		set("theme_override_styles/panel", selected_style)
	elif item == null:
		set('theme_override_styles/panel', empty_style)
	else:
		set('theme_override_styles/panel', default_style)
		
func pick_from_slot():
	remove_child(item)
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.add_child(item)
	item = null
	refresh_style()
	
func put_into_slot(new_item):
	item = new_item
	item.position = Vector2(8, 8)
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()
	
#signals to remove item when quantity runs out
func remove_item():
	remove_child(item)
	item = null
	refresh_style()
	
#function to decrement item
func change_quantity(quantity := 1):
	if (item):
		item.item_quantity = item.item_quantity - quantity
		item.set_item(item.item_name, item.item_quantity)
		refresh_style()
	
func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instantiate()
		item.position = Vector2(8, 8)
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
	refresh_style()

