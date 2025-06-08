extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.current_game == "menu":
		$resume.disabled = true
	$deck_style/deck_style_option.select(Globals.deck_style_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_deck_style_option_item_selected(index: int) -> void:
	Globals.deck_style_index = index
	var settings = ConfigFile.new()
	settings.load("user://settings.cfg")
	settings.set_value("settings", "deck_style_index", index)
	settings.save("user://settings.cfg")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_resume_pressed() -> void:
	if FileAccess.file_exists("user://saved_"+Globals.current_game+".tscn"):
		var scene = ResourceLoader.load("user://saved_"+Globals.current_game+".tscn")
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://scenes/"+Globals.current_game+".tscn")


func _on_clear_saves_pressed() -> void:
	DirAccess.remove_absolute("user://saved_klondike.tscn")
	DirAccess.remove_absolute("user://saved_freecell.tscn")
	DirAccess.remove_absolute("user://saved_spider.tscn")
	var settings = ConfigFile.new()
	settings.load("user://settings.cfg")
	settings.erase_section("stats")
	settings.save("user://settings.cfg")
