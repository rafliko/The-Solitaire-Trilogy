extends Node2D

@export var deck = []
var card_scene = preload("res://scenes/card.tscn")

var block_autosolve = false
@export var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $deck.texture != load("res://sprites/deck_refresh.png"):
		$deck.texture = load(Globals.deck_styles[Globals.deck_style_index])
	$timer.start()
	if FileAccess.file_exists("user://saved_klondike.tscn"): return
	
	# Create and shuffle deck
	for i in range(13):
		for j in range(4):
			deck.push_back({"value":i, "suit":j})
	deck.shuffle()
	print(deck)
	
	# Deal the cards
	for i in range(7):
		var parent = $columns.get_child(i)
		
		for j in range(i+1):
			var drawn_card = deck.pop_back()
			var card_instance = card_scene.instantiate()
			card_instance.value = drawn_card.value
			card_instance.suit = drawn_card.suit
			if drawn_card.suit == 0 or drawn_card.suit == 3: card_instance.isdark = true
			else: card_instance.isdark = false
			if j!=i: card_instance.is_hidden = true
			if j!=0: card_instance.position.y = Globals.default_offset
			parent.add_child(card_instance)
			parent = card_instance

func _process(delta: float) -> void:	
	# Look for cards to automatically move to foundation
	if not block_autosolve: autosolve()
	
	# Check for win
	check_win()


func _on_settings_button_pressed() -> void:
	save()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_restart_button_pressed() -> void:
	DirAccess.remove_absolute("user://saved_klondike.tscn")
	get_tree().change_scene_to_file("res://scenes/klondike.tscn")


func _on_timer_timeout() -> void:
	var a = ""
	var b = ""
	t += 1
	# if t%10==1: save() # Autosave every 10 seconds
	if int(t/60) < 10: a = "0"
	if int(t%60) < 10: b = "0"
	$timer_label.text = a + str(int(t/60)) + ":" + b + str(t%60)


func validate_move(target: Node, parent_card: Node) -> bool:
	if target.is_in_group("cards") and target.is_pile_card: # Placed on a pile card
		return false
	
	if ((target.get_child_count() < 3 and target.is_in_group("cards") and target.value == parent_card.value+1 and target.isdark != parent_card.isdark) or # All value and suit requirements met
		(target.is_in_group("columns") and target.get_child_count() == 1 and parent_card.value == 12)): # Empty column
		return true
	
	if parent_card.get_child_count() < 3: # Single card
		if ((target.is_in_group("foundations") and parent_card.value == 0) or # Placed ace on foundation
			(target.is_in_group("cards") and target.is_foundation_card and target.value == parent_card.value-1 and target.suit == parent_card.suit)): # Placed on lower foundation card: 
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
		if not $youwin.visible:
			update_stats()
			$youwin.visible = true
		$timer.stop()


func _on_deck_button_pressed() -> void:
	if len(deck) == 0: # Empty deck - refresh
		while $card_pile.get_child_count() > 0:
			var top_card = Globals.get_top_card($card_pile.get_child(0))
			deck.push_back({"value":top_card.value, "suit":top_card.suit})
			top_card.free()
		if len(deck) != 0:
			$deck.texture = load(Globals.deck_styles[Globals.deck_style_index])
			$deck.region_enabled = true
		return
	
	var drawn_card = deck.pop_back()
	var card_instance = card_scene.instantiate()
	card_instance.value = drawn_card.value
	card_instance.suit = drawn_card.suit
	card_instance.is_pile_card = true
	if drawn_card.suit == 0 or drawn_card.suit == 3: card_instance.isdark = true
	else: card_instance.isdark = false
	if $card_pile.get_child_count() == 0:
		$card_pile.add_child(card_instance)
	else:
		Globals.get_top_card($card_pile.get_child(0)).add_child(card_instance)
	
	if len(deck) == 0: # Last card drawn
		$deck.texture = load("res://sprites/deck_refresh.png")
		$deck.region_enabled = false


func save() -> void:
	var scene = PackedScene.new()
	for c in get_tree().get_nodes_in_group("cards"):
		c.set_owner(self)
	scene.pack(self);
	ResourceSaver.save(scene, "user://saved_klondike.tscn")


func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST or 
		what == NOTIFICATION_APPLICATION_PAUSED or 
		what == NOTIFICATION_WM_GO_BACK_REQUEST):
		save() # Save when quitting
		get_tree().quit()


func update_stats() -> void:
	var settings = ConfigFile.new()
	settings.load("user://settings.cfg")
	var w = settings.get_value("stats", "klondike_games_won")
	if w == null: w = 0
	settings.set_value("stats", "klondike_games_won", w+1)
	var bt = settings.get_value("stats", "klondike_best_time")
	if bt == null: bt = INF
	if t < bt: settings.set_value("stats", "klondike_best_time", t)
	settings.save("user://settings.cfg")
