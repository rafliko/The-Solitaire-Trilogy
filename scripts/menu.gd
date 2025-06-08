extends Control

var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	Globals.current_game = "menu"
	$card1.texture = load(Globals.deck_styles[Globals.deck_style_index])
	$card2.texture = load(Globals.deck_styles[Globals.deck_style_index])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t+=delta
	$card1.rotation = sin(t*2)/5
	$card2.rotation = sin(t*2-PI)/5


func _on_freecell_pressed() -> void:
	Globals.current_game = "freecell"
	if FileAccess.file_exists("user://saved_freecell.tscn"):
		var scene = ResourceLoader.load("user://saved_freecell.tscn")
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://scenes/freecell.tscn")


func _on_klondike_pressed() -> void:
	Globals.current_game = "klondike"
	if FileAccess.file_exists("user://saved_klondike.tscn"):
		var scene = ResourceLoader.load("user://saved_klondike.tscn")
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://scenes/klondike.tscn")


func _on_spider_pressed() -> void:
	Globals.current_game = "spider"
	if FileAccess.file_exists("user://saved_spider.tscn"):
		var scene = ResourceLoader.load("user://saved_spider.tscn")
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file("res://scenes/spider.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func load_settings() -> void:
	var settings = ConfigFile.new()
	if settings.load("user://settings.cfg") != OK: return
	Globals.deck_style_index = settings.get_value("settings", "deck_style_index")


func _on_rules_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/rules.tscn")
