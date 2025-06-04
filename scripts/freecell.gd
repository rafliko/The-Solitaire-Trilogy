extends Node2D

var deck = []
var card_scene = preload("res://scenes/card.tscn")

var open_freecells = 4
var open_columns = 0
var block_autosolve = false
@export var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$timer.start()
	if FileAccess.file_exists("user://saved_freecell.tscn"): return
		
	# Create and shuffle deck
	for i in range(13):
		for j in range(4):
			deck.push_back({"value":i, "suit":j})
	deck.shuffle()
	print(deck)
	
	# Deal the cards
	var range = null
	for i in range(8):
		var parent = $columns.get_child(i)
		
		if i < 4: range = range(7)
		else: range = range(6)
		
		for j in range:
			var drawn_card = deck.pop_back()
			var card_instance = card_scene.instantiate()
			card_instance.value = drawn_card.value
			card_instance.suit = drawn_card.suit
			if drawn_card.suit == 0 or drawn_card.suit == 3: card_instance.isdark = true
			else: card_instance.isdark = false
			if j!=0: card_instance.position.y = Globals.default_offset
			parent.add_child(card_instance)
			parent = card_instance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	# Count open columns
	var colcount = 0
	for c in $columns.get_children():
		if c.get_child_count() == 1: colcount+=1
	open_columns = colcount
	
	# Count open freecells
	var fccount = 0
	for c in $freecells.get_children():
		if c.get_child_count() == 1: fccount+=1
	open_freecells = fccount
	
	# Look for cards to automatically move to foundation
	if not block_autosolve: autosolve()
	
	# Check for win
	check_win()


func validate_move(target: Node, parent_card: Node) -> bool:
	if ((target.is_in_group("cards") and Globals.count_sequence(parent_card, 1) > pow(2,open_columns) * (open_freecells+1)) or # Too many cards in sequence (moving to card)
		(target.is_in_group("columns") and Globals.count_sequence(parent_card, 1) > pow(2,open_columns-1) * (open_freecells+1)) or # Too many cards in sequence (moving to column)
		(target.is_in_group("cards") and target.is_freecell_card)): # Placed on card in freecell slot
		return false
	
	if ((target.get_child_count() < 3 and target.is_in_group("cards") and target.value == parent_card.value+1 and target.isdark != parent_card.isdark) or # All value and suit requirements met
		(target.is_in_group("columns") and target.get_child_count() == 1)): # Empty column
		return true
	
	if parent_card.get_child_count() < 3: # Single card
		if ((target.is_in_group("foundations") and parent_card.value == 0) or # Placed ace on foundation
			(target.is_in_group("cards") and target.is_foundation_card and target.value == parent_card.value-1 and target.suit == parent_card.suit) or # Placed on lower foundation card
			(target.is_in_group("freecells") and target.get_child_count() == 1 )): # Placed on empty freecell
			return true
	
	return false


func validate_sequence(parent_card: Node) -> bool:
	if parent_card.is_in_group("cards") and parent_card.is_foundation_card: return false # Can't move foundation cards
	if parent_card.get_child_count() > 2: # More than 1 card
		if ((parent_card.isdark != parent_card.get_child(2).isdark) and 
			(parent_card.value == parent_card.get_child(2).value+1)):
			return validate_sequence(parent_card.get_child(2))
		else:
			return false
	else:
		return true


func autosolve() -> void:
	for c in get_tree().get_nodes_in_group("cards"):
		if c.get_child_count() < 3 and !c.is_foundation_card and c.value == Globals.get_min_foundation($foundations):
			block_autosolve = true
			if $foundations.get_child(c.suit).get_child_count() > 1:
				var new_parent = Globals.get_top_card($foundations.get_child(c.suit).get_child(1))
				if new_parent != c:
					c.reparent(new_parent)
			else:
				c.reparent($foundations.get_child(c.suit))
			c.is_pile_card = false
			c.is_freecell_card = false
			c.is_foundation_card = true
			c.move_to_foundation = true
			return


func check_win() -> void:
	var count = 0
	for f in $foundations.get_children():
		if f.get_child_count()>1 and Globals.count_sequence(f.get_child(1), 1) == 13:
			count+=1
	if count == 4:
		$youwin.visible = true
		$timer.stop()


func save() -> void:
	var scene = PackedScene.new()
	for c in get_tree().get_nodes_in_group("cards"):
		c.set_owner(self)
	scene.pack(self);
	ResourceSaver.save(scene, "user://saved_freecell.tscn")


func _on_timer_timeout() -> void:
	var a = ""
	var b = ""
	t += 1
	if int(t/60) < 10: a = "0"
	if int(t%60) < 10: b = "0"
	$timer_label.text = a + str(int(t/60)) + ":" + b + str(t%60)
	

func _on_settings_button_pressed() -> void:
	save()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_restart_button_pressed() -> void:
	DirAccess.remove_absolute("user://saved_freecell.tscn")
	get_tree().change_scene_to_file("res://scenes/freecell.tscn")


func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST or 
		what == NOTIFICATION_APPLICATION_PAUSED or 
		what == NOTIFICATION_WM_GO_BACK_REQUEST):
		save() # Save when quitting
		get_tree().quit()
