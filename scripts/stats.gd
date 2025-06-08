extends Control


func _ready() -> void:
	load_game_data("klondike")
	load_game_data("freecell")
	load_game_data("spider")


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func load_game_data(game: String):	
	var settings = ConfigFile.new()
	settings.load("user://settings.cfg")
	var w = settings.get_value("stats", game+"_games_won")
	var bt = settings.get_value("stats", game+"_best_time")
	if bt != null:
		var a = ""
		var b = ""
		if int(bt/60) < 10: a = "0"
		if int(bt%60) < 10: b = "0"
		bt = a + str(int(bt/60)) + ":" + b + str(bt%60)
		get_node(game+"_stats").set_item_text(1, "Best time: "+str(bt))
	if w != null: get_node(game+"_stats").set_item_text(2, "Games won: "+str(w))
