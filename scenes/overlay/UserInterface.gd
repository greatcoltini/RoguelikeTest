extends CanvasLayer

@onready var inventory = $Inventory
@onready var hotbar = $Hotbar
@onready var tooltip = $tooltip
@onready var player
@onready var toast = $Toast


var fishing_interface
var timer


# fishing overlay
@onready var fishing_interface_scn = preload("res://overlay/fishing_minigame.tscn")

var event_keys_num = ["1", "2", "3", "4", "5", "6", "7", "8"]

@onready var holding_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	tooltip = $tooltip
	PlayerInventory.item_added.connect(toast.play_toast)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory(null)
		
	if event.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_up()
	if event.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_down()
		
	for key in event_keys_num:
		if event.is_action_pressed(key):
			PlayerInventory.active_item_set(int(key) - 1)
			
# refactor this to toggle visiblity of all nodes
func toggle_inventory(item):
	# base action off of inventory main
	var inventory_main = get_tree().get_nodes_in_group("InventoryMain")[0]
	var inventory_items = get_tree().get_nodes_in_group("InventoryItems")
	
	
	if inventory_main.visible:
		inventory_main.visible = false
		for i in range(inventory_items.size()):
			inventory_items[i].visible = inventory_main.visible
	elif !inventory_main.visible and item:
		inventory_main.visible = true
		for i in range(inventory_items.size()):
			inventory_items[i].visible = false
		item.visible = true
	else:
		inventory_main.visible = true
		
	inventory.initialize_inventory()
	inventory.tooltip.visible = false
		
func start_fishing():
	fishing_interface = fishing_interface_scn.instantiate()
	fishing_interface.environment = player.environment
	add_child(fishing_interface)
	fishing_interface.fishing_finished.connect(self.unfreeze_controls)
	fishing_interface.position = Vector2(193, 192)
	
	
# play animation to hide freeze effect
func unfreeze_controls():
	timer = Timer.new()
	timer.wait_time = 1
	fishing_interface.queue_free()
	timer.timeout.connect(toggle_action_disabled)
	player.state_machine.travel("Fishing_Exit")
	add_child(timer)
	timer.start()
	
func toggle_action_disabled():
	player.action_disabled = false
	player.is_fishing = false
	timer.queue_free()
		
		
	
