extends Node2D

@export var deck = []
var card_scene = preload("res://scenes/card.tscn")

var block_autosolve = false
@export var t = 0


func _ready() -> void:
	$timer.start()
	for c in $deck.get_children():
		if c.name != "Button":
			c.texture = load(Globals.deck_styles[Globals.deck_style_index])
	if FileAccess.file_exists("user://saved_spider.tscn"): return
	
	# Create and shuffle deck
	for i in range(13):
		for j in range(8):
			deck.push_back({"value":i, "suit":3})
	deck.shuffle()
	print(deck)
	
	# Deal the cards
	var r = 0
	for i in range(10):
		var parent = $columns.get_child(i)
		
		if i < 4: r = 6
		else: r = 5
		
		for j in range(r):
			var drawn_card = deck.pop_back()
			var card_instance = card_scene.instantiate()
			card_instance.value = drawn_card.value
			card_instance.suit = drawn_card.suit
			if drawn_card.suit == 0 or drawn_card.suit == 3: card_instance.isdark = true
			else: card_instance.isdark = false
			if j!=r-1: card_instance.is_hidden = true
			if j!=0: card_instance.position.y = Globals.default_offset_spider
			parent.add_child(card_instance)
			parent = card_instance


func _process(delta: float) -> void:
	# Chek for complete sequences
	check_complete()
	
	# Check for win
	check_win()


func validate_move(target: Node, parent_card: Node) -> bool:	
	if ((target.get_child_count() < 3 and target.is_in_group("cards") and target.value == parent_card.value+1) or # Value requirements met
		(target.is_in_group("columns") and target.get_child_count() == 1)): # Empty column
		return true
	
	return false


func validate_sequence(parent_card: Node) -> bool:
	if parent_card.get_child_count() > 2: # More than 1 card
		if parent_card.value == parent_card.get_child(2).value+1:
			return validate_sequence(parent_card.get_child(2))
		else:
			return false
	else:
		return true


func _on_timer_timeout() -> void:
	var a = ""
	var b = ""
	t += 1
	# if t%10==1: save() # Autosave every 10 seconds
	if int(t/60) < 10: a = "0"
	if int(t%60) < 10: b = "0"
	$timer_label.text = a + str(int(t/60)) + ":" + b + str(t%60)


func _on_settings_button_pressed() -> void:
	save()
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_restart_button_pressed() -> void:
	DirAccess.remove_absolute("user://saved_spider.tscn")
	get_tree().change_scene_to_file("res://scenes/spider.tscn")


func _on_deck_button_pressed() -> void:
	for col in $columns.get_children():
		if col.get_child_count() == 1: return
	
	for col in $columns.get_children():
		var drawn_card = deck.pop_back()
		var card_instance = card_scene.instantiate()
		card_instance.value = drawn_card.value
		card_instance.suit = drawn_card.suit
		card_instance.isdark = true
		card_instance.position.y = Globals.default_offset_spider
		Globals.get_top_card(col.get_child(1)).add_child(card_instance)
	
	$deck.get_child($deck.get_child_count()-1).free()
	if $deck.get_child_count() == 1: $deck/Button.disabled = true


func check_win() -> void:
	var count = 0
	for col in $columns.get_children():
		if col.get_child_count() == 1:
			count+=1
	if count == 10:
		$youwin.visible = true
		$timer.stop()


func check_complete() -> void:
	for c in get_tree().get_nodes_in_group("cards"):
		if validate_sequence(c) and Globals.count_sequence(c, 1) == 13:
			c.free()
			return


func save() -> void:
	var scene = PackedScene.new()
	for c in get_tree().get_nodes_in_group("cards"):
		c.set_owner(self)
	scene.pack(self);
	ResourceSaver.save(scene, "user://saved_spider.tscn")


func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST or 
		what == NOTIFICATION_APPLICATION_PAUSED or 
		what == NOTIFICATION_WM_GO_BACK_REQUEST):
		save() # Save when quitting
		get_tree().quit()
