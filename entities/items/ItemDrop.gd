extends Area2D

var item_name 
var item_quantity
var quantity_label
	
func load_item(item, quantity := 1):
	item_name = item
	item_quantity = quantity
	quantity_label = $quantity
	
	if item_quantity > 1:
		quantity_label.visible = true
		quantity_label.text = str(item_quantity)
	else:
		quantity_label.visible = false
		
	$Sprite2D.texture = load("res://entities/item_drops//" + item_name + ".png")
	
func _on_body_entered(body):
	if body.name == 'player_cat':
		#PlayerInventory.add_item(item_name, item_quantity)
		get_tree().queue_delete(self)

