extends Node2D

const SlotClass = preload("res://scenes/overlay/slot.gd")
const CraftingSlot = preload("res://scenes/overlay/crafting_slot.tscn")
const Item = preload("res://entities/items/turnip/turnip_item.tscn")

# inventory variables
@onready var inventory_slots = $InventorySlots
@onready var inventory_tabs = $InventoryTabs

# collect hotbar slots here as well for crafting ?

# crafting variables
@onready var crafting_page
@onready var crafting_tab_icon = $"InventoryTabs/Crafting-tab"
@onready var crafting_slots_grid = $CraftingPanel/CraftingSlots
@onready var crafting_requirements_grid = $CraftingRequirements
@onready var crafting_button = $CraftingButton
@onready var crafting_menus = $CraftingPanel/CraftingMenus.get_children()
@onready var tooltip = get_parent().get_node("tooltip")

var readied_crafting_menu


var tab_list = []
var crafting_tab_list = ["Building"]
var crafting_tab_slots = []
var crafting_slot
var current_crafting_recipe

var current_tab

# Called when the node enters the scene tree for the first time.
func _ready():
	
	### INVENTORY INIT
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].gui_input.connect(slot_gui_input.bind(slots[i]))
		slots[i].mouse_entered.connect(mouse_entered.bind(slots[i]))
		slots[i].mouse_exited.connect(mouse_exited)
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY
	initialize_inventory()
	# connect inv buttons
	var tabs = $InventoryTabs.get_children()
	for i in range(tabs.size()):
		tab_list.append(tabs[i])
		tabs[i].gui_input.connect(tab_gui_input.bind(tabs[i]))
	current_tab = tab_list[3]
	current_tab.anim_player.play("open")
	
	
	change_inventory_panel(current_tab)
	
func tab_gui_input(event: InputEvent, tab: Panel):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			change_inventory_panel(tab)
			for tab_panel in tab_list:
				if tab_panel.sprite.get_frame() != 0 and tab_panel != tab:
					tab_panel.anim_player.play("close")
			tab.anim_player.play("open")
	
			
func change_inventory_panel(tab: Panel):
	if readied_crafting_menu != null:
		readied_crafting_menu.modulate = "#ffffffff"
		readied_crafting_menu = null
	if tab == tab_list[3]:
		for child in get_children():
			if child in get_tree().get_nodes_in_group("Inventory") or child in get_tree().get_nodes_in_group("General"):
				child.visible = true
			else:
				child.visible = false
	elif tab == tab_list[1]:
		for child in get_children():
			if child in get_tree().get_nodes_in_group("Skills") or child in get_tree().get_nodes_in_group("General"):
				child.visible = true
			else:
				child.visible = false
	elif tab == tab_list[2]:
		for child in get_children():
			if child in get_tree().get_nodes_in_group("Accomplishments") or child in get_tree().get_nodes_in_group("General"):
				child.visible = true
			else:
				child.visible = false
				
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])
		
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# check if we are holding an item
			if find_parent("UserInterface").holding_item != null:
				# if the slot is empty, we put the item into the slot
				if !slot.item:
					left_click_empty_slot(slot)
				else:
					# there is an item in the slot, lets check if its the same or different
					if find_parent("UserInterface").holding_item.item_name == slot.item.item_name:
						left_click_same_item(slot)
					# different item, so swap:
					else:
						left_click_different_item(event, slot)
			elif slot.item:
				left_click_not_holding(slot)
				
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if find_parent("UserInterface").holding_item != null:
				if !slot.item:
					pass
				else:
					# if we right click an item slot with an identical item, pull one item from slot into hand
					if (find_parent("UserInterface").holding_item.item_name == slot.item.item_name):
						#TODO
						pass
			elif slot.item:
				right_click_not_holding(slot)
				
func mouse_entered(slot: SlotClass):
	# we want to display the slot item and description at a tooltip below mouse position
	if slot.item != null:
			tooltip.global_position = get_global_mouse_position()
			tooltip.get_node("PanelContainer").custom_minimum_size = Vector2(20, 50)
			tooltip.visible = true
			tooltip.get_node("PanelContainer/item_name").text = slot.item.item_name
			tooltip.get_node("PanelContainer/item_extra").text = "\n \n" + slot.item.item_desc
			tooltip.get_node("PanelContainer/item_extra").text += "\n Value: " + str(slot.item.item_value)

func mouse_exited():
	tooltip.visible = false
				
func _input(_event):
	if find_parent("UserInterface") != null:
		if find_parent("UserInterface").holding_item:
			find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()
			tooltip.global_position = get_global_mouse_position() + Vector2(0, 10)
			tooltip.visible = true
			tooltip.get_node("PanelContainer/item_name").text = find_parent("UserInterface").holding_item.item_name
			tooltip.get_node("PanelContainer").custom_minimum_size = Vector2(20, 20)
			tooltip.get_node("PanelContainer/item_extra").text = ""

func left_click_empty_slot(slot):
	if (able_to_put_into_slot(slot)):
		# placing holding item, into slot
		slot.put_into_slot(find_parent("UserInterface").holding_item)
		# must update dictionary by adding item
		PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
		find_parent("UserInterface").holding_item = null
	
func left_click_different_item(event, slot):
	if (able_to_put_into_slot(slot)):
		# first remove item from slot
		PlayerInventory.remove_item(slot)
		PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
		var temp_item = slot.item
		slot.pick_from_slot()
		temp_item.global_position = event.global_position
		slot.put_into_slot(find_parent("UserInterface").holding_item)
		find_parent("UserInterface").holding_item = temp_item
	
func left_click_same_item(slot):
	# we need to see the stack size to determine if we can add
	if (able_to_put_into_slot(slot)):
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_quantity
		if able_to_add >= find_parent("UserInterface").holding_item.item_quantity:
			PlayerInventory.add_item_quantity(slot, find_parent("UserInterface").holding_item.item_quantity)
			slot.item.add_item_quantity(find_parent("UserInterface").holding_item.item_quantity)
			find_parent("UserInterface").holding_item.queue_free()
			find_parent("UserInterface").holding_item = null
		else:
			PlayerInventory.add_item_quantity(slot, able_to_add)
			slot.item.add_item_quantity(able_to_add)
			find_parent("UserInterface").holding_item.decrease_item_quantity(able_to_add)

func left_click_not_holding(slot):
	# remove item from slot
	PlayerInventory.remove_item(slot)
	find_parent("UserInterface").holding_item = slot.item
	slot.pick_from_slot()
	find_parent("UserInterface").holding_item.global_position = get_global_mouse_position() 
	
func right_click_not_holding(slot):
	# remove half of quantity from slot and place into hand
	if slot.item.item_quantity >= 2:
		var temp_item = Item.instantiate()
		temp_item.set_item(slot.item.item_name, slot.item.item_quantity / 2)
		PlayerInventory.decrease_item_quantity(slot.slot_index, slot.slot_type == SlotClass.SlotType.HOTBAR, slot.item.item_quantity / 2)
		find_parent("UserInterface").add_child(temp_item)
		find_parent("UserInterface").holding_item = temp_item
		find_parent("UserInterface").holding_item.global_position = get_global_mouse_position() 
	else:
		left_click_not_holding(slot)
		
func able_to_put_into_slot(slot: SlotClass):
	var holding_item = find_parent("UserInterface").holding_item

	return true
		
