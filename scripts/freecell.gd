extends Node2D

var deck = []
var card_scene = preload("res://scenes/card.tscn")

var open_freecells = 4
var open_columns = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create and shuffle deck
	Globals.current_game = "freecell"
	for i in range(13):
		for j in range(4):
			deck.push_back({"value":i, "suit":j})
	deck.shuffle()
	print(deck)
	
	# Deal the cards
	var indx = 0
	var range = null
	for i in range(8):
		var parent = $columns.get_child(i)
		
		if i < 4: range = range(7)
		else: range = range(6)
		
		for j in range:
			var card_instance = card_scene.instantiate()
			card_instance.value = deck[indx].value
			card_instance.suit = deck[indx].suit
			if deck[indx].suit == 0 or deck[indx].suit == 3: card_instance.isdark = true
			else: card_instance.isdark = false
			card_instance.region_rect = Rect2(deck[indx].value*Globals.card_width, deck[indx].suit*Globals.card_height, Globals.card_width, Globals.card_height)
			if j!=0: card_instance.position.y = Globals.default_offset
			parent.add_child(card_instance)
			parent = card_instance
			indx+=1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var count = 0
	for c in $columns.get_children():
		if c.get_child_count() == 1: count+=1
	open_columns = count
	
	count = 0
	for c in $freecells.get_children():
		if c.get_child_count() == 1: count+=1
	open_freecells = count
	
	count = 0
	for c in $columns.get_children():
		if c.get_child_count() == 1 or validate_sequence(c.get_child(1)): count+=1
	if count == 8:
		$solve_button.visible = true
	

func validate_move(target: Node, parent_card: Node) -> bool:
	if ((target.is_in_group("cards") and count_sequence(parent_card, 1) > pow(2,open_columns) * (open_freecells+1)) or
		(target.is_in_group("columns") and count_sequence(parent_card, 1) > pow(2,open_columns-1) * (open_freecells+1)) or 
		target.is_in_group("freecell_cards")):
		return false
	
	if ((target.get_child_count() < 3 and target.is_in_group("cards") and target.value == parent_card.value+1 and target.isdark != parent_card.isdark) or
		(target.is_in_group("columns") and target.get_child_count() == 1) or 
		(target.is_in_group("freecells") and target.get_child_count() == 1 and parent_card.get_child_count() < 3)):
		return true
	elif (parent_card.get_child_count() < 3 and 
		  ((target.is_in_group("foundations") and parent_card.value == 0) or 
		  (target.is_in_group("foundation_cards") and target.value == parent_card.value-1 and target.suit == parent_card.suit))):
		return true
	else: 
		return false


func validate_sequence(parent_card: Node) -> bool:
	if parent_card.is_in_group("foundation_cards"): return false
	if parent_card.get_child_count() > 2:
		if ((parent_card.isdark != parent_card.get_child(2).isdark) and 
			(parent_card.value == parent_card.get_child(2).value+1)):
			return validate_sequence(parent_card.get_child(2))
		else:
			return false
	else:
		return true


func count_sequence(parent_card: Node, depth: int) -> int:
	if parent_card.get_child_count() > 2:
		return count_sequence(parent_card.get_child(2), depth+1)
	else:
		return depth


func _on_solve_button_pressed() -> void:
	for c in get_tree().get_nodes_in_group("cards"):
		c.queue_free()
	$RichTextLabel.visible = true
