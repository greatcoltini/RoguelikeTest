extends Panel

var default_tex = preload("res://assets/item_slot_filled.png")
var selected_tex = preload("res://assets/item_slot_selected.png")

var default_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null

var ItemClass = preload("res://entities/items/turnip/turnip_item.tscn")
var item = null
var slot_type
var slot_index
var materials
var produce

# Called when the node enters the scene tree for the first time.
func _ready():
	default_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	default_style.texture = default_tex
	selected_style.texture = selected_tex
	#set("theme_override_styles/panel", default_tex)
	set_style("default")
	
		
func initialize_item(item_name, item_quantity):
	if item != null:
		item = null
	ItemClass = load("res://entities/items/turnip/turnip_item.tscn")
	item = ItemClass.instantiate()
	item.position = Vector2(8, 9)
	item.scale = Vector2(0.9, 0.9)
	item.set_item(item_name, item_quantity)
	add_child(item)
	
func set_style(style):
	if style == "default":
		set("theme_override_styles/panel", default_style)
	else:
		set("theme_override_styles/panel", selected_style)
	


